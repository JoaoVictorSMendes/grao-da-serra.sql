const express = require('express');
const cors = require('cors');
const path = require('path');
const pool = require('./db');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// encapsula as rotas e traduz os erros do MySQL
const rota = (fn) => async (req, res) => {
  try {
    res.json(await fn(req, res));
  } catch (err) {
    if (err.sqlState === '45000') {
      return res.status(400).json({ erro: err.sqlMessage });
    }
    console.error(err);
    res.status(500).json({ erro: 'Erro no servidor: ' + (err.sqlMessage || err.message) });
  }
};

const consulta = async (sql, params = []) => {
  const [linhas] = await pool.query(sql, params);
  return linhas;
};

app.get('/api/cardapio', rota(() =>
  consulta('SELECT * FROM vw_cardapio ORDER BY categoria, produto')));

app.get('/api/clientes', rota(() =>
  consulta('SELECT id_cliente, nome, cpf FROM cliente ORDER BY nome')));

app.get('/api/funcionarios', rota(() =>
  consulta('SELECT id_funcionario, nome, cargo FROM funcionario ORDER BY nome')));

app.get('/api/categorias', rota(() =>
  consulta('SELECT id_categoria, nome FROM categoria ORDER BY nome')));

// o OUT da procedure precisa ser lido na mesma conexão
app.post('/api/pedidos', rota(async (req) => {
  const { id_cliente, id_funcionario } = req.body;
  const conn = await pool.getConnection();
  try {
    await conn.query('CALL sp_abrir_pedido(?, ?, @id)', [id_cliente, id_funcionario]);
    const [linhas] = await conn.query('SELECT @id AS id_pedido');
    return linhas[0];
  } finally {
    conn.release();
  }
}));

app.get('/api/pedidos', rota((req) => {
  const { status } = req.query;
  if (status) {
    return consulta('SELECT * FROM vw_pedidos_detalhados WHERE status = ? ORDER BY id_pedido DESC', [status]);
  }
  return consulta('SELECT * FROM vw_pedidos_detalhados ORDER BY id_pedido DESC');
}));

app.get('/api/pedidos/:id/itens', rota(async (req) => {
  const itens = await consulta(
    `SELECT i.id_produto, p.nome AS produto, i.quantidade, i.preco_unitario
       FROM item_pedido i
       JOIN produto p ON p.id_produto = i.id_produto
      WHERE i.id_pedido = ?
      ORDER BY p.nome`, [req.params.id]);
  const [{ total }] = await consulta('SELECT fn_total_pedido(?) AS total', [req.params.id]);
  return { itens, total };
}));

app.post('/api/pedidos/:id/itens', rota(async (req) => {
  const { id_produto, quantidade } = req.body;
  await consulta('CALL sp_adicionar_item(?, ?, ?)', [req.params.id, id_produto, quantidade]);
  return { ok: true };
}));

app.delete('/api/pedidos/:id/itens/:produto', rota(async (req) => {
  await consulta('DELETE FROM item_pedido WHERE id_pedido = ? AND id_produto = ?',
    [req.params.id, req.params.produto]);
  return { ok: true };
}));

app.post('/api/pedidos/:id/finalizar', rota(async (req) => {
  await consulta('CALL sp_finalizar_pedido(?)', [req.params.id]);
  const linhas = await consulta(
    'SELECT id_pedido, desconto_percentual, valor_total FROM pedido WHERE id_pedido = ?',
    [req.params.id]);
  return linhas[0];
}));

app.get('/api/gerencia/repor', rota(() =>
  consulta('SELECT * FROM vw_produtos_para_repor ORDER BY faltam DESC')));

app.get('/api/gerencia/vendas', rota(() =>
  consulta('SELECT * FROM vw_vendas_por_categoria ORDER BY faturamento DESC')));

app.post('/api/gerencia/reajuste', rota(async (req) => {
  const { id_categoria, percentual } = req.body;
  await consulta('CALL sp_reajustar_precos_categoria(?, ?)', [id_categoria, percentual]);
  return { ok: true };
}));

app.get('/api/gerencia/historico', rota(() =>
  consulta(`SELECT h.*, p.nome AS produto
              FROM historico_preco h
              JOIN produto p ON p.id_produto = h.id_produto
             ORDER BY h.data_alteracao DESC, h.id_historico DESC`)));

const PORTA = 3000;
app.listen(PORTA, () => console.log(`Servidor rodando em http://localhost:${PORTA}`));
