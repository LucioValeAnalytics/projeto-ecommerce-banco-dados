CREATE SCHEMA ecommerce;

CREATE TABLE ecommerce.cliente (
    id_cliente INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cpf CHAR(11),
    cnpj CHAR(14),

    CONSTRAINT cliente_cpf_ou_cnpj
        CHECK (
            (cpf IS NOT NULL AND cnpj IS NULL)
            OR
            (cpf IS NULL AND cnpj IS NOT NULL)
        )
);

CREATE TABLE ecommerce.fornecedor (
    id_fornecedor INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE
);

CREATE TABLE ecommerce.produto (
    id_produto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT,
    valor NUMERIC(10,2) NOT NULL,
    id_fornecedor INTEGER NOT NULL,

    CONSTRAINT fk_produto_fornecedor
        FOREIGN KEY (id_fornecedor)
        REFERENCES ecommerce.fornecedor (id_fornecedor),

    CONSTRAINT produto_valor_valido
        CHECK (valor >= 0)
);

CREATE TABLE ecommerce.estoque (
    id_estoque INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_produto INTEGER NOT NULL UNIQUE,
    quantidade INTEGER NOT NULL,

    CONSTRAINT fk_estoque_produto
        FOREIGN KEY (id_produto)
        REFERENCES ecommerce.produto (id_produto),

    CONSTRAINT estoque_quantidade_valida
        CHECK (quantidade >= 0)
);

CREATE TABLE ecommerce.pedido (
    id_pedido INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    data_pedido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30) NOT NULL,

    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES ecommerce.cliente (id_cliente)
);

/* ITEM_PEDIDO resolve a relação N:N entre PEDIDO e PRODUTO */
CREATE TABLE ecommerce.item_pedido (
    id_item_pedido INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pedido INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    preco_unitario NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_item_pedido_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES ecommerce.pedido (id_pedido),

    CONSTRAINT fk_item_pedido_produto
        FOREIGN KEY (id_produto)
        REFERENCES ecommerce.produto (id_produto),

    CONSTRAINT item_pedido_quantidade_valida
        CHECK (quantidade > 0),

    CONSTRAINT item_pedido_preco_valido
        CHECK (preco_unitario >= 0)
);

CREATE TABLE ecommerce.pagamento (
    id_pagamento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    tipo VARCHAR(30) NOT NULL,
    descricao VARCHAR(150),

    CONSTRAINT fk_pagamento_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES ecommerce.cliente (id_cliente)
);

CREATE TABLE ecommerce.entrega (
    id_entrega INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pedido INTEGER NOT NULL UNIQUE,
    status_logistica VARCHAR(30) NOT NULL,
    codigo_rastreio VARCHAR(50),

    logradouro VARCHAR(150) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado CHAR(2) NOT NULL,
    cep CHAR(8) NOT NULL,

    CONSTRAINT fk_entrega_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES ecommerce.pedido (id_pedido),

    CONSTRAINT entrega_status_valido
        CHECK (status_logistica IN (
            'PENDENTE',
            'ENVIADO',
            'EM_TRANSITO',
            'ENTREGUE',
            'CANCELADA'
        )),

    CONSTRAINT entrega_estado_valido
        CHECK (estado ~ '^[A-Z]{2}$'),

    CONSTRAINT entrega_cep_valido
        CHECK (cep ~ '^[0-9]{8}$')
);

