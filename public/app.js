const $ = (seletor) => document.querySelector(seletor);
const esc = (t) => String(t).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const moeda = (v) => Number(v).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
const percentual = (v) => Number(v).toLocaleString('pt-BR', { minimumFractionDigits: 2 }) + '%';

function dataBr(texto) {
  const [data, hora] = String(texto).split(' ');
  const [ano, mes, dia] = data.split('-');
  return `${dia}/${mes}/${ano} ${hora.slice(0, 5)}`;
}

let pedidoAtual = null;
let filtroStatus = '';
let tempoToast;

function mostrarToast(mensagem, tipo = 'sucesso') {
  const toast = $('#toast');
  toast.textContent = mensagem;
  toast.className = `toast ${tipo}`;
  clearTimeout(tempoToast);
  tempoToast = setTimeout(() => toast.classList.add('oculto'), 5000);
}

// executa uma operação, mostra o resultado e recarrega as telas
async function executar(operacao, mensagemSucesso) {
  try {
    const resultado = await operacao();
    if (mensagemSucesso) mostrarToast(mensagemSucesso);
    await recarregarTudo();
    return resultado;
  } catch (erro) {
    mostrarToast(erro.message, 'erro');
  }
}

function linhasOuVazio(linhas, colunas, html) {
  return linhas.length ? html : `<tr><td colspan="${colunas}" class="vazio">Nenhum registro.</td></tr>`;
}

async function carregarCardapio() {
  const itens = await listarCardapio();

  const porCategoria = {};
  itens.forEach((i) => (porCategoria[i.categoria] ||= []).push(i));

  $('#cardapio').innerHTML = Object.entries(porCategoria).map(([categoria, produtos]) => `
    <h3 class="categoria-titulo">${esc(categoria)}</h3>
    <div class="itens-cardapio">
      ${produtos.map((p) => `
        <div class="produto ${p.situacao === 'ESGOTADO' ? 'esgotado' : ''}">
          <div>
            <div class="nome">${esc(p.produto)}</div>
            ${p.situacao === 'ESGOTADO' ? '<span class="badge esgotado">Esgotado</span>' : ''}
            ${p.situacao === 'REPOR' ? '<span class="badge repor">Estoque baixo</span>' : ''}
          </div>
          <div class="preco">${moeda(p.preco)}</div>
        </div>`).join('')}
    </div>`).join('');

  const vendaveis = itens.filter((i) => i.situacao !== 'ESGOTADO');
  const selecionado = $('#sel-produto').value;
  $('#sel-produto').innerHTML = vendaveis
    .map((p) => `<option value="${p.id_produto}">${esc(p.produto)} - ${moeda(p.preco)}</option>`).join('');
  if (selecionado) $('#sel-produto').value = selecionado;
}

async function carregarSelects() {
  const [clientes, funcionarios, categorias] = await Promise.all([
    listarClientes(), listarFuncionarios(), listarCategorias()
  ]);
  $('#sel-cliente').innerHTML = clientes
    .map((c) => `<option value="${c.id_cliente}">${esc(c.nome)} (${esc(c.cpf)})</option>`).join('');
  $('#sel-funcionario').innerHTML = funcionarios
    .map((f) => `<option value="${f.id_funcionario}">${esc(f.nome)} - ${esc(f.cargo)}</option>`).join('');
  $('#sel-categoria').innerHTML = categorias
    .map((c) => `<option value="${c.id_categoria}">${esc(c.nome)}</option>`).join('');
}

async function carregarItensPedido() {
  if (!pedidoAtual) return;
  const { itens, total } = await listarItensPedido(pedidoAtual);
  $('#itens-pedido').innerHTML = linhasOuVazio(itens, 4, itens.map((i) => `
    <tr>
      <td>${esc(i.produto)}</td>
      <td class="num">${i.quantidade}</td>
      <td class="num">${moeda(i.preco_unitario)}</td>
      <td class="num"><button class="btn-remover" data-produto="${i.id_produto}">Remover</button></td>
    </tr>`).join(''));
  $('#total-parcial').textContent = moeda(total);
}

async function carregarPedidos() {
  const pedidos = await listarPedidos(filtroStatus);
  $('#tab-pedidos').innerHTML = linhasOuVazio(pedidos, 9, pedidos.map((p) => `
    <tr>
      <td>#${p.id_pedido}</td>
      <td>${dataBr(p.data_pedido)}</td>
      <td><span class="badge ${p.status.toLowerCase()}">${p.status}</span></td>
      <td>${esc(p.cliente)}</td>
      <td>${esc(p.atendente)}</td>
      <td class="num">${p.qtd_itens}</td>
      <td class="num">${moeda(p.valor_bruto)}</td>
      <td class="num">${percentual(p.desconto_percentual)}</td>
      <td class="num">${p.status === 'PAGO' ? moeda(p.valor_total) : '-'}</td>
    </tr>`).join(''));
}

async function carregarGerencia() {
  const [repor, vendas, historico] = await Promise.all([
    listarProdutosParaRepor(), listarVendasPorCategoria(), listarHistoricoPrecos()
  ]);

  $('#tab-repor').innerHTML = linhasOuVazio(repor, 5, repor.map((p) => `
    <tr>
      <td>${esc(p.produto)}</td>
      <td>${esc(p.categoria)}</td>
      <td class="num">${p.estoque}</td>
      <td class="num">${p.estoque_minimo}</td>
      <td class="num"><strong>${p.faltam}</strong></td>
    </tr>`).join(''));

  $('#tab-vendas').innerHTML = linhasOuVazio(vendas, 3, vendas.map((v) => `
    <tr>
      <td>${esc(v.categoria)}</td>
      <td class="num">${v.unidades}</td>
      <td class="num">${moeda(v.faturamento)}</td>
    </tr>`).join(''));

  $('#tab-historico').innerHTML = linhasOuVazio(historico, 5, historico.map((h) => `
    <tr>
      <td>${dataBr(h.data_alteracao)}</td>
      <td>${esc(h.produto)}</td>
      <td class="num">${moeda(h.preco_antigo)}</td>
      <td class="num">${moeda(h.preco_novo)}</td>
      <td>${esc(h.usuario)}</td>
    </tr>`).join(''));
}

function atualizarAreaPedido() {
  $('#area-pedido').classList.toggle('oculto', !pedidoAtual);
  $('#num-pedido').textContent = pedidoAtual ? `#${pedidoAtual}` : '';
}

async function recarregarTudo() {
  atualizarAreaPedido();
  await Promise.all([carregarCardapio(), carregarItensPedido(), carregarPedidos(), carregarGerencia()]);
}

document.querySelectorAll('.aba').forEach((botao) => {
  botao.addEventListener('click', () => {
    document.querySelectorAll('.aba').forEach((b) => b.classList.toggle('ativa', b === botao));
    document.querySelectorAll('.painel').forEach((p) => p.classList.add('oculto'));
    $(`#aba-${botao.dataset.aba}`).classList.remove('oculto');
  });
});

document.querySelectorAll('.filtro').forEach((botao) => {
  botao.addEventListener('click', async () => {
    document.querySelectorAll('.filtro').forEach((b) => b.classList.toggle('ativa', b === botao));
    filtroStatus = botao.dataset.status;
    await executar(carregarPedidos);
  });
});

$('#btn-abrir').addEventListener('click', async () => {
  const resultado = await executar(
    () => abrirPedido($('#sel-cliente').value, $('#sel-funcionario').value));
  if (resultado) {
    pedidoAtual = resultado.id_pedido;
    $('#resumo-pedido').classList.add('oculto');
    mostrarToast(`Pedido #${pedidoAtual} aberto.`);
    await recarregarTudo();
  }
});

$('#btn-adicionar').addEventListener('click', () => {
  executar(
    () => adicionarItem(pedidoAtual, $('#sel-produto').value, Number($('#inp-qtd').value)),
    'Item adicionado.');
});

$('#itens-pedido').addEventListener('click', (e) => {
  const botao = e.target.closest('.btn-remover');
  if (botao) executar(() => removerItem(pedidoAtual, botao.dataset.produto), 'Item removido.');
});

$('#btn-finalizar').addEventListener('click', async () => {
  const pedido = await executar(() => finalizarPedido(pedidoAtual));
  if (!pedido) return;
  $('#resumo-pedido').innerHTML = `
    <h2>Pedido #${pedido.id_pedido} finalizado</h2>
    <p>Desconto de fidelidade: <strong>${percentual(pedido.desconto_percentual)}</strong></p>
    <p>Valor total: <strong>${moeda(pedido.valor_total)}</strong></p>`;
  $('#resumo-pedido').classList.remove('oculto');
  pedidoAtual = null;
  mostrarToast(`Pedido #${pedido.id_pedido} finalizado.`);
  await recarregarTudo();
});

$('#btn-reajustar').addEventListener('click', () => {
  executar(
    () => reajustarPrecos($('#sel-categoria').value, Number($('#inp-percentual').value)),
    'Preços reajustados.');
});

(async () => {
  try {
    await carregarSelects();
    await recarregarTudo();
  } catch (erro) {
    mostrarToast('Não foi possível conectar ao servidor: ' + erro.message, 'erro');
  }
})();
