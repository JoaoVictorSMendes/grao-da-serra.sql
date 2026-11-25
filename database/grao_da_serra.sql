SET SQL_SAFE_UPDATES = 0;

DROP DATABASE IF EXISTS grao_da_serra;
CREATE DATABASE grao_da_serra CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE grao_da_serra;

CREATE TABLE categoria (
    id_categoria INT          NOT NULL AUTO_INCREMENT,
    nome         VARCHAR(50)  NOT NULL,
    descricao    VARCHAR(150),
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nome UNIQUE (nome)
);

CREATE TABLE produto (
    id_produto     INT          NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(80)  NOT NULL,
    preco          DECIMAL(8,2) NOT NULL,
    estoque        INT          NOT NULL DEFAULT 0,
    estoque_minimo INT          NOT NULL DEFAULT 5,
    ativo          BOOLEAN      NOT NULL DEFAULT TRUE,
    id_categoria   INT          NOT NULL,
    CONSTRAINT pk_produto PRIMARY KEY (id_produto),
    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria)
);

CREATE TABLE cliente (
    id_cliente    INT          NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(100) NOT NULL,
    cpf           CHAR(14)     NOT NULL,
    email         VARCHAR(100),
    telefone      VARCHAR(20),
    data_cadastro DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_cpf UNIQUE (cpf)
);

CREATE TABLE funcionario (
    id_funcionario INT          NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(100) NOT NULL,
    cargo          VARCHAR(40)  NOT NULL,
    data_admissao  DATE         NOT NULL,
    CONSTRAINT pk_funcionario PRIMARY KEY (id_funcionario)
);

CREATE TABLE pedido (
    id_pedido           INT           NOT NULL AUTO_INCREMENT,
    data_pedido         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status              ENUM('ABERTO','PAGO','CANCELADO') NOT NULL DEFAULT 'ABERTO',
    desconto_percentual DECIMAL(4,2)  NOT NULL DEFAULT 0,
    valor_total         DECIMAL(10,2) NOT NULL DEFAULT 0,
    id_cliente          INT           NOT NULL,
    id_funcionario      INT           NOT NULL,
    CONSTRAINT pk_pedido PRIMARY KEY (id_pedido),
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente),
    CONSTRAINT fk_pedido_funcionario FOREIGN KEY (id_funcionario)
        REFERENCES funcionario (id_funcionario)
);

CREATE TABLE item_pedido (
    id_pedido      INT          NOT NULL,
    id_produto     INT          NOT NULL,
    quantidade     INT          NOT NULL,
    preco_unitario DECIMAL(8,2) NOT NULL,
    CONSTRAINT pk_item_pedido PRIMARY KEY (id_pedido, id_produto),
    CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido),
    CONSTRAINT fk_item_produto FOREIGN KEY (id_produto)
        REFERENCES produto (id_produto)
);

CREATE TABLE historico_preco (
    id_historico   INT          NOT NULL AUTO_INCREMENT,
    id_produto     INT          NOT NULL,
    preco_antigo   DECIMAL(8,2) NOT NULL,
    preco_novo     DECIMAL(8,2) NOT NULL,
    data_alteracao DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario        VARCHAR(100) NOT NULL,
    CONSTRAINT pk_historico_preco PRIMARY KEY (id_historico),
    CONSTRAINT fk_historico_produto FOREIGN KEY (id_produto)
        REFERENCES produto (id_produto)
);

INSERT INTO categoria (id_categoria, nome, descricao) VALUES
    (1, 'Cafés',           'Bebidas quentes preparadas na hora'),
    (2, 'Bebidas geladas', 'Sucos e chás gelados'),
    (3, 'Salgados',        'Salgados assados servidos no balcão'),
    (4, 'Doces',           'Fatias de bolos, cucas e tortas'),
    (5, 'Empório',         'Produtos embalados para levar para casa');

INSERT INTO produto (id_produto, nome, preco, estoque, estoque_minimo, ativo, id_categoria) VALUES
    ( 1, 'Café expresso',              6.00, 200, 30, TRUE,  1),
    ( 2, 'Cappuccino',                11.50, 120, 20, TRUE,  1),
    ( 3, 'Café coado na hora',         8.00, 150, 20, TRUE,  1),
    ( 4, 'Suco de laranja',            9.00,  40, 10, TRUE,  2),
    ( 5, 'Chá gelado de hibisco',      8.50,   8, 10, TRUE,  2),
    ( 6, 'Pão de queijo',              5.50,  60, 15, TRUE,  3),
    ( 7, 'Empada de palmito',          9.50,   4, 10, TRUE,  3),
    ( 8, 'Quiche de alho-poró',       12.00,   0,  6, TRUE,  3),
    ( 9, 'Cuca de banana (fatia)',     7.50,  25,  8, TRUE,  4),
    (10, 'Strudel de maçã',           13.00,  12,  5, TRUE,  4),
    (11, 'Bolo de cenoura (fatia)',    8.00,  18,  6, TRUE,  4),
    (12, 'Café em grãos 250 g',       34.90,  30,  8, TRUE,  5),
    (13, 'Geleia colonial de morango',18.00,   5,  5, TRUE,  5),
    (14, 'Mel silvestre 300 g',       27.00,  14,  4, TRUE,  5),
    (15, 'Torta alemã (fatia)',       12.50,   0,  4, FALSE, 4);

INSERT INTO cliente (id_cliente, nome, cpf, email, telefone) VALUES
    (1, 'Ana Beatriz Schroeder', '111.111.111-11', 'ana.schroeder@email.com',  '(47) 99111-1111'),
    (2, 'Rafael Linzmeyer',      '222.222.222-22', 'rafael.linz@email.com',    '(47) 99222-2222'),
    (3, 'Luana Pscheidt',        '333.333.333-33', 'luana.pscheidt@email.com', '(47) 99333-3333'),
    (4, 'Diego Fendrich',        '444.444.444-44', NULL,                       '(47) 99444-4444'),
    (5, 'Helena Rudnick',        '555.555.555-55', 'helena.rudnick@email.com', NULL);

INSERT INTO funcionario (id_funcionario, nome, cargo, data_admissao) VALUES
    (1, 'Bruno Tavares', 'Atendente', '2024-03-04'),
    (2, 'Sofia Grossl',  'Caixa',     '2025-01-13'),
    (3, 'Otávio Weiss',  'Gerente',   '2022-07-01');

INSERT INTO pedido (id_pedido, data_pedido, status, id_cliente, id_funcionario) VALUES
    ( 1, '2026-11-03 08:20:00', 'PAGO',      1, 1),
    ( 2, '2026-11-03 15:45:00', 'PAGO',      2, 1),
    ( 3, '2026-11-04 09:10:00', 'PAGO',      1, 2),
    ( 4, '2026-11-05 16:30:00', 'PAGO',      3, 1),
    ( 5, '2026-11-06 08:05:00', 'PAGO',      1, 2),
    ( 6, '2026-11-07 10:50:00', 'PAGO',      2, 1),
    ( 7, '2026-11-07 17:15:00', 'CANCELADO', 4, 2),
    ( 8, '2026-11-09 08:30:00', 'PAGO',      1, 1),
    ( 9, '2026-11-10 14:00:00', 'ABERTO',    3, 2),
    (10, '2026-11-10 14:25:00', 'ABERTO',    2, 1);

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
    ( 1,  1, 2,  6.00), ( 1,  6, 4,  5.50),
    ( 2,  2, 1, 11.50), ( 2, 10, 1, 13.00),
    ( 3,  3, 1,  8.00), ( 3,  9, 2,  7.50), ( 3, 12, 1, 34.90),
    ( 4,  4, 2,  9.00), ( 4,  7, 2,  9.50),
    ( 5,  1, 1,  6.00), ( 5, 11, 1,  8.00),
    ( 6,  2, 2, 11.50), ( 6,  6, 6,  5.50), ( 6, 14, 1, 27.00),
    ( 7, 13, 2, 18.00),
    ( 8,  1, 1,  6.00), ( 8,  9, 1,  7.50),
    ( 9,  5, 2,  8.50), ( 9, 10, 1, 13.00),
    (10,  3, 2,  8.00), (10,  6, 2,  5.50);

UPDATE pedido p
   SET p.valor_total = (SELECT SUM(i.quantidade * i.preco_unitario)
                          FROM item_pedido i
                         WHERE i.id_pedido = p.id_pedido)
 WHERE p.status = 'PAGO';

-- ================= SOLUÇÃO =================

-- Questão 1: fn_total_pedido
DROP FUNCTION IF EXISTS fn_total_pedido;
DELIMITER //
CREATE FUNCTION fn_total_pedido(p_id_pedido INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);

    SELECT COALESCE(SUM(quantidade * preco_unitario), 0.00)
      INTO v_total
      FROM item_pedido
     WHERE id_pedido = p_id_pedido;

    RETURN v_total;
END //
DELIMITER ;

-- Questão 2: fn_situacao_estoque
DROP FUNCTION IF EXISTS fn_situacao_estoque;
DELIMITER //
CREATE FUNCTION fn_situacao_estoque(p_id_produto INT)
RETURNS VARCHAR(20)
READS SQL DATA
BEGIN
    DECLARE v_estoque INT;
    DECLARE v_minimo INT;

    SELECT estoque, estoque_minimo
      INTO v_estoque, v_minimo
      FROM produto
     WHERE id_produto = p_id_produto;

    IF v_estoque = 0 THEN
        RETURN 'ESGOTADO';
    ELSEIF v_estoque > 0 AND v_estoque <= v_minimo THEN
        RETURN 'REPOR';
    END IF;

    RETURN 'OK';
END //
DELIMITER ;

-- Questão 3: fn_desconto_fidelidade
DROP FUNCTION IF EXISTS fn_desconto_fidelidade;
DELIMITER //
CREATE FUNCTION fn_desconto_fidelidade(p_id_cliente INT)
RETURNS DECIMAL(4,2)
READS SQL DATA
BEGIN
    DECLARE v_pagos INT;

    SELECT COUNT(*)
      INTO v_pagos
      FROM pedido
     WHERE id_cliente = p_id_cliente
       AND status = 'PAGO';

    IF v_pagos >= 4 THEN
        RETURN 10.00;
    ELSEIF v_pagos >= 2 THEN
        RETURN 5.00;
    END IF;

    RETURN 0.00;
END //
DELIMITER ;

-- Questão 4: sp_abrir_pedido
DROP PROCEDURE IF EXISTS sp_abrir_pedido;
DELIMITER //
CREATE PROCEDURE sp_abrir_pedido(
    IN  p_id_cliente     INT,
    IN  p_id_funcionario INT,
    OUT p_id_pedido      INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM cliente WHERE id_cliente = p_id_cliente) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente não encontrado.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM funcionario WHERE id_funcionario = p_id_funcionario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Funcionário não encontrado.';
    END IF;

    INSERT INTO pedido (id_cliente, id_funcionario)
    VALUES (p_id_cliente, p_id_funcionario);

    SET p_id_pedido = LAST_INSERT_ID();
END //
DELIMITER ;

-- Questão 5: sp_adicionar_item
DROP PROCEDURE IF EXISTS sp_adicionar_item;
DELIMITER //
CREATE PROCEDURE sp_adicionar_item(
    IN p_id_pedido  INT,
    IN p_id_produto INT,
    IN p_quantidade INT
)
BEGIN
    DECLARE v_status  VARCHAR(20);
    DECLARE v_preco   DECIMAL(8,2);
    DECLARE v_estoque INT;
    DECLARE v_ativo   BOOLEAN;

    SELECT status INTO v_status
      FROM pedido
     WHERE id_pedido = p_id_pedido;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pedido não encontrado.';
    END IF;

    IF v_status <> 'ABERTO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O pedido não está aberto e não aceita novos itens.';
    END IF;

    SELECT preco, estoque, ativo
      INTO v_preco, v_estoque, v_ativo
      FROM produto
     WHERE id_produto = p_id_produto;

    IF v_preco IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produto não encontrado.';
    END IF;

    IF v_ativo = FALSE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produto inativo, fora do cardápio.';
    END IF;

    IF p_quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A quantidade deve ser maior que zero.';
    END IF;

    IF v_estoque < p_quantidade THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente para a quantidade solicitada.';
    END IF;

    INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario)
    VALUES (p_id_pedido, p_id_produto, p_quantidade, v_preco);
END //
DELIMITER ;

-- Questão 6: sp_finalizar_pedido
DROP PROCEDURE IF EXISTS sp_finalizar_pedido;
DELIMITER //
CREATE PROCEDURE sp_finalizar_pedido(IN p_id_pedido INT)
BEGIN
    DECLARE v_status   VARCHAR(20);
    DECLARE v_cliente  INT;
    DECLARE v_bruto    DECIMAL(10,2);
    DECLARE v_desconto DECIMAL(4,2);

    SELECT status, id_cliente
      INTO v_status, v_cliente
      FROM pedido
     WHERE id_pedido = p_id_pedido;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pedido não encontrado.';
    END IF;

    IF v_status <> 'ABERTO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Só é possível finalizar pedidos abertos.';
    END IF;

    SET v_bruto = fn_total_pedido(p_id_pedido);

    IF v_bruto <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O pedido não possui itens.';
    END IF;

    SET v_desconto = fn_desconto_fidelidade(v_cliente);

    UPDATE pedido
       SET desconto_percentual = v_desconto,
           valor_total         = ROUND(v_bruto * (1 - v_desconto / 100), 2),
           status              = 'PAGO'
     WHERE id_pedido = p_id_pedido;
END //
DELIMITER ;

-- Questão 7: sp_reajustar_precos_categoria
DROP PROCEDURE IF EXISTS sp_reajustar_precos_categoria;
DELIMITER //
CREATE PROCEDURE sp_reajustar_precos_categoria(
    IN p_id_categoria INT,
    IN p_percentual   DECIMAL(5,2)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM categoria WHERE id_categoria = p_id_categoria) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Categoria não encontrada.';
    END IF;

    IF p_percentual IS NULL OR p_percentual <= -100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Percentual inválido: deve ser maior que -100.';
    END IF;

    UPDATE produto
       SET preco = ROUND(preco * (1 + p_percentual / 100), 2)
     WHERE id_categoria = p_id_categoria;
END //
DELIMITER ;

-- Questão 8: vw_cardapio
CREATE OR REPLACE VIEW vw_cardapio AS
SELECT p.id_produto,
       c.nome AS categoria,
       p.nome AS produto,
       p.preco,
       fn_situacao_estoque(p.id_produto) AS situacao
  FROM produto p
  JOIN categoria c ON c.id_categoria = p.id_categoria
 WHERE p.ativo = TRUE;

-- Questão 9: vw_pedidos_detalhados
CREATE OR REPLACE VIEW vw_pedidos_detalhados AS
SELECT p.id_pedido,
       p.data_pedido,
       p.status,
       c.nome AS cliente,
       f.nome AS atendente,
       COUNT(i.id_produto) AS qtd_itens,
       fn_total_pedido(p.id_pedido) AS valor_bruto,
       p.desconto_percentual,
       p.valor_total
  FROM pedido p
  JOIN cliente c     ON c.id_cliente = p.id_cliente
  JOIN funcionario f ON f.id_funcionario = p.id_funcionario
  LEFT JOIN item_pedido i ON i.id_pedido = p.id_pedido
 GROUP BY p.id_pedido, p.data_pedido, p.status, c.nome, f.nome,
          p.desconto_percentual, p.valor_total;

-- Questão 10: vw_produtos_para_repor
CREATE OR REPLACE VIEW vw_produtos_para_repor AS
SELECT p.id_produto,
       p.nome AS produto,
       c.nome AS categoria,
       p.estoque,
       p.estoque_minimo,
       p.estoque_minimo - p.estoque AS faltam
  FROM produto p
  JOIN categoria c ON c.id_categoria = p.id_categoria
 WHERE p.ativo = TRUE
   AND p.estoque <= p.estoque_minimo;

-- Questão 11: vw_vendas_por_categoria
CREATE OR REPLACE VIEW vw_vendas_por_categoria AS
SELECT c.nome AS categoria,
       COALESCE(SUM(i.quantidade), 0) AS unidades,
       COALESCE(SUM(i.quantidade * i.preco_unitario), 0.00) AS faturamento
  FROM categoria c
  LEFT JOIN produto pr ON pr.id_categoria = c.id_categoria
  LEFT JOIN (item_pedido i
             JOIN pedido pe ON pe.id_pedido = i.id_pedido AND pe.status = 'PAGO')
         ON i.id_produto = pr.id_produto
 GROUP BY c.id_categoria, c.nome;

-- Questão 12: trg_item_baixa_estoque
DROP TRIGGER IF EXISTS trg_item_baixa_estoque;
DELIMITER //
CREATE TRIGGER trg_item_baixa_estoque
AFTER INSERT ON item_pedido
FOR EACH ROW
BEGIN
    UPDATE produto
       SET estoque = estoque - NEW.quantidade
     WHERE id_produto = NEW.id_produto;
END //
DELIMITER ;

-- Questão 13: trg_item_devolve_estoque
DROP TRIGGER IF EXISTS trg_item_devolve_estoque;
DELIMITER //
CREATE TRIGGER trg_item_devolve_estoque
AFTER DELETE ON item_pedido
FOR EACH ROW
BEGIN
    UPDATE produto
       SET estoque = estoque + OLD.quantidade
     WHERE id_produto = OLD.id_produto;
END //
DELIMITER ;

-- Questão 14: trg_produto_historico_preco
DROP TRIGGER IF EXISTS trg_produto_historico_preco;
DELIMITER //
CREATE TRIGGER trg_produto_historico_preco
AFTER UPDATE ON produto
FOR EACH ROW
BEGIN
    IF OLD.preco <> NEW.preco THEN
        INSERT INTO historico_preco (id_produto, preco_antigo, preco_novo, usuario)
        VALUES (OLD.id_produto, OLD.preco, NEW.preco, CURRENT_USER());
    END IF;
END //
DELIMITER ;

-- Questão 15: trg_pedido_bloqueia_alteracao
DROP TRIGGER IF EXISTS trg_pedido_bloqueia_alteracao;
DELIMITER //
CREATE TRIGGER trg_pedido_bloqueia_alteracao
BEFORE UPDATE ON pedido
FOR EACH ROW
BEGIN
    IF OLD.status IN ('PAGO', 'CANCELADO') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pedido pago ou cancelado não pode ser alterado.';
    END IF;
END //
DELIMITER ;
