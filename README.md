# Empório & Café Grão da Serra - Interface do sistema de pedidos

## Arquitetura

```
Navegador (HTML/CSS/JS + api.js)  --fetch-->  API Express (server.js)  --mysql2-->  MySQL (grao_da_serra)
```

- **Front-end** (`public/`): telas em HTML, CSS e JavaScript puro. Todas as chamadas ao servidor ficam em `api.js`.
- **API** (`server.js`): recebe as requisições, consulta as views e chama as procedures. Mensagens de `SIGNAL SQLSTATE '45000'` viram erro 400 e aparecem no toast da tela.
- **Banco** (`db.js`): pool de conexões `mysql2/promise`. Toda a regra de negócio (totais, descontos, estoque, histórico) está no MySQL; o JavaScript não calcula nada disso.

## Pré-requisitos

1. Node.js 18 ou superior.
2. Banco `grao_da_serra` criado, com as functions, procedures, views e triggers (rode o arquivo `.sql` completo no Workbench antes).

## Configuração

Abra `db.js` e ajuste `user` e `password` (e `host`/`port`, se necessário):

```js
user: 'root',
password: 'SUA_SENHA_AQUI',
```

## Como rodar

```
npm install
npm start
```

Acesse http://localhost:3000

## Rotas da API

| Método | Rota | Usa no banco |
|---|---|---|
| GET | /api/cardapio | `vw_cardapio` |
| GET | /api/clientes, /api/funcionarios, /api/categorias | tabelas |
| POST | /api/pedidos | `sp_abrir_pedido` |
| GET | /api/pedidos?status= | `vw_pedidos_detalhados` |
| GET/POST | /api/pedidos/:id/itens | `item_pedido` / `sp_adicionar_item` |
| DELETE | /api/pedidos/:id/itens/:produto | `DELETE` em `item_pedido` |
| POST | /api/pedidos/:id/finalizar | `sp_finalizar_pedido` |
| GET | /api/gerencia/repor | `vw_produtos_para_repor` |
| GET | /api/gerencia/vendas | `vw_vendas_por_categoria` |
| POST | /api/gerencia/reajuste | `sp_reajustar_precos_categoria` |
| GET | /api/gerencia/historico | `historico_preco` |

## Texto para o relatório

A interface foi desenvolvida em HTML, CSS e JavaScript, e se comunica com o banco de dados por meio de um servidor intermediário em Node.js com Express. O navegador envia requisições HTTP (fetch) para a API, que usa a biblioteca mysql2 para abrir um pool de conexões com o banco MySQL `grao_da_serra`, configurado no arquivo `db.js` com usuário e senha. A API apenas consulta as views (`vw_cardapio`, `vw_pedidos_detalhados`, `vw_produtos_para_repor` e `vw_vendas_por_categoria`) e executa as procedures (`sp_abrir_pedido`, `sp_adicionar_item`, `sp_finalizar_pedido` e `sp_reajustar_precos_categoria`), de modo que cálculos de totais, descontos de fidelidade, baixa de estoque e histórico de preços ficam inteiramente no banco, por meio das functions e dos triggers. Quando uma procedure interrompe a operação com `SIGNAL SQLSTATE '45000'`, a API devolve a mensagem em português e a interface a exibe em uma barra no topo da tela.
