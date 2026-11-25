const BASE = '/api';

async function requisitar(url, opcoes = {}) {
  const resposta = await fetch(BASE + url, {
    headers: { 'Content-Type': 'application/json' },
    ...opcoes
  });
  const dados = await resposta.json().catch(() => ({}));
  if (!resposta.ok) {
    throw new Error(dados.erro || 'Não foi possível completar a operação.');
  }
  return dados;
}

const enviar = (metodo, corpo) => ({ method: metodo, body: JSON.stringify(corpo) });

function listarCardapio() {
  return requisitar('/cardapio');
}

function listarClientes() {
  return requisitar('/clientes');
}

function listarFuncionarios() {
  return requisitar('/funcionarios');
}

function listarCategorias() {
  return requisitar('/categorias');
}

function abrirPedido(idCliente, idFuncionario) {
  return requisitar('/pedidos', enviar('POST', { id_cliente: idCliente, id_funcionario: idFuncionario }));
}

function listarItensPedido(idPedido) {
  return requisitar(`/pedidos/${idPedido}/itens`);
}

function adicionarItem(idPedido, idProduto, quantidade) {
  return requisitar(`/pedidos/${idPedido}/itens`, enviar('POST', { id_produto: idProduto, quantidade }));
}

function removerItem(idPedido, idProduto) {
  return requisitar(`/pedidos/${idPedido}/itens/${idProduto}`, { method: 'DELETE' });
}

function finalizarPedido(idPedido) {
  return requisitar(`/pedidos/${idPedido}/finalizar`, { method: 'POST' });
}

function listarPedidos(status = '') {
  return requisitar('/pedidos' + (status ? `?status=${status}` : ''));
}

function listarProdutosParaRepor() {
  return requisitar('/gerencia/repor');
}

function listarVendasPorCategoria() {
  return requisitar('/gerencia/vendas');
}

function reajustarPrecos(idCategoria, percentual) {
  return requisitar('/gerencia/reajuste', enviar('POST', { id_categoria: idCategoria, percentual }));
}

function listarHistoricoPrecos() {
  return requisitar('/gerencia/historico');
}
