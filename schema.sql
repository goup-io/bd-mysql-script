USE myStock;

CREATE TABLE acesso_loja (
    id INT AUTO_INCREMENT NOT NULL,
    tipo SMALLINT NOT NULL CHECK (tipo BETWEEN 0 AND 1),
    descricao VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE cargo (
    id INT AUTO_INCREMENT NOT NULL,
    descricao VARCHAR(255),
    nome VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE categoria (
    id INT AUTO_INCREMENT NOT NULL,
    nome VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (nome)
);

CREATE TABLE cor (
    id INT AUTO_INCREMENT NOT NULL,
    nome VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (nome)
);

CREATE TABLE status_historico_produto (
    id INT AUTO_INCREMENT NOT NULL,
    status ENUM('VENDIDO', 'DEVOLVIDO', 'ABATIDO'),
    PRIMARY KEY (id)
);

CREATE TABLE status_transferencia (
    id INT AUTO_INCREMENT NOT NULL,
    status ENUM('PENDENTE', 'ACEITO', 'NEGADO'),
    PRIMARY KEY (id),
    UNIQUE (status)
);

CREATE TABLE status_venda (
    id INT AUTO_INCREMENT NOT NULL,
    status ENUM('PENDENTE', 'FINALIZADA', 'CANCELADA'),
    PRIMARY KEY (id),
    UNIQUE (status)
);

CREATE TABLE tamanho (
    id INT AUTO_INCREMENT NOT NULL,
    numero INT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (numero)
);

CREATE TABLE tipo (
    id INT AUTO_INCREMENT NOT NULL,
    nome VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (nome)
);

CREATE TABLE tipo_pagamento (
    id INT AUTO_INCREMENT NOT NULL,
    metodo ENUM('CREDITO', 'DEBITO', 'PIX', 'DINHEIRO') NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE tipo_venda (
    desconto DOUBLE NOT NULL,
    id INT AUTO_INCREMENT NOT NULL,
    tipo ENUM('VAREJO', 'ATACADO', 'ESPECIAL') NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (tipo)
);

CREATE TABLE loja (
    id INT AUTO_INCREMENT NOT NULL,
    numero INT NOT NULL,
    cep VARCHAR(255) NOT NULL,
    cnpj VARCHAR(255) NOT NULL,
    complemento VARCHAR(255),
    nome VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (cnpj),
    UNIQUE (nome)
);

CREATE TABLE modelo (
    categoria_id INT NOT NULL,
    id INT AUTO_INCREMENT NOT NULL,
    tipo_id INT NOT NULL,
    nome VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (nome, categoria_id, tipo_id),
    UNIQUE (nome, categoria_id),
    UNIQUE (nome, tipo_id),
    FOREIGN KEY (categoria_id) REFERENCES categoria(id),
    FOREIGN KEY (tipo_id) REFERENCES tipo(id)
);

CREATE TABLE produto (
    cor_id INT NOT NULL,
    id INT AUTO_INCREMENT NOT NULL,
    modelo_id INT NOT NULL,
    valor_custo DOUBLE NOT NULL,
    valor_revenda DOUBLE NOT NULL,
    nome VARCHAR(255),
    PRIMARY KEY (id),
    UNIQUE (cor_id, modelo_id),
    FOREIGN KEY (cor_id) REFERENCES cor(id),
    FOREIGN KEY (modelo_id) REFERENCES modelo(id)
);

CREATE TABLE etp (
    id INT AUTO_INCREMENT NOT NULL,
    loja_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    tamanho_id INT NOT NULL,
    codigo VARCHAR(255) NOT NULL,
    item_promocional ENUM('SIM', 'NAO'),
    PRIMARY KEY (id),
    FOREIGN KEY (loja_id) REFERENCES loja(id),
    FOREIGN KEY (produto_id) REFERENCES produto(id),
    FOREIGN KEY (tamanho_id) REFERENCES tamanho(id)
);

CREATE TABLE alertas_estoque (
    etp_id INT NOT NULL,
    id INT AUTO_INCREMENT NOT NULL,
    data_hora DATETIME(6) NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (etp_id) REFERENCES etp(id) ON DELETE CASCADE
);

CREATE TABLE usuario (
    cargo_id INT NOT NULL,
    codigo_venda INT,
    id INT AUTO_INCREMENT NOT NULL,
    loja_id INT NOT NULL,
    nome VARCHAR(30),
    email VARCHAR(255),
    telefone VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (codigo_venda),
    UNIQUE (email),
    FOREIGN KEY (cargo_id) REFERENCES cargo(id),
    FOREIGN KEY (loja_id) REFERENCES loja(id)
);

CREATE TABLE login (
    id INT AUTO_INCREMENT NOT NULL,
    usuario_id INT NOT NULL,
    senha VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (usuario_id),
    UNIQUE (username),
    FOREIGN KEY (usuario_id) REFERENCES usuario(id)
);

CREATE TABLE loja_login (
    acesso_loja_id INT NOT NULL,
    id INT AUTO_INCREMENT NOT NULL,
    loja_id INT NOT NULL,
    senha VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (acesso_loja_id) REFERENCES acesso_loja(id),
    FOREIGN KEY (loja_id) REFERENCES loja(id)
);

CREATE TABLE redefinir_senha (
    ativo TINYINT NOT NULL,
    id INT AUTO_INCREMENT NOT NULL,
    login_id INT,
    token VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (login_id) REFERENCES login(id)
);

CREATE TABLE venda (
    desconto DOUBLE,
    id INT AUTO_INCREMENT NOT NULL,
    status_venda_id INT NOT NULL,
    tipo_venda_id INT NOT NULL,
    usuario_id INT NOT NULL,
    valor_total DOUBLE,
    data_hora DATETIME(6) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (status_venda_id) REFERENCES status_venda(id),
    FOREIGN KEY (tipo_venda_id) REFERENCES tipo_venda(id),
    FOREIGN KEY (usuario_id) REFERENCES usuario(id)
);

CREATE TABLE produto_venda (
    desconto DOUBLE,
    etp_id INT,
    id INT AUTO_INCREMENT NOT NULL,
    item_promocional TINYINT CHECK (item_promocional BETWEEN 0 AND 1),
    quantidade INT,
    valor_unitario DOUBLE,
    venda_id INT,
    PRIMARY KEY (id),
    FOREIGN KEY (etp_id) REFERENCES etp(id),
    FOREIGN KEY (venda_id) REFERENCES venda(id)
);

CREATE TABLE pagamento (
    id INT AUTO_INCREMENT NOT NULL,
    qtd_parcelas INT,
    tipo_pagamento_id INT,
    valor DOUBLE,
    venda_id INT,
    PRIMARY KEY (id),
    FOREIGN KEY (tipo_pagamento_id) REFERENCES tipo_pagamento(id),
    FOREIGN KEY (venda_id) REFERENCES venda(id)
);


CREATE TABLE historico_produto (
    id INT AUTO_INCREMENT NOT NULL,
    produto_venda_id INT,
    status_historico_produto_id INT,
    data_hora DATETIME(6),
    PRIMARY KEY (id),
    FOREIGN KEY (produto_venda_id) REFERENCES produto_venda(id),
    FOREIGN KEY (status_historico_produto_id) REFERENCES status_historico_produto(id)
);

CREATE TABLE configuracao_loja (
    id INT AUTO_INCREMENT NOT NULL,
    limite_estoque_alerta INT,
    loja_id INT,
    PRIMARY KEY (id),
    UNIQUE (loja_id),
    FOREIGN KEY (loja_id) REFERENCES loja(id)
);

CREATE TABLE transferencia (
    coletor_id INT NOT NULL,
    etp_id INT NOT NULL,
    id INT AUTO_INCREMENT NOT NULL,
    liberador_id INT,
    quantidade_liberada INT,
    quantidade_solicitada INT NOT NULL,
    status_transferencia_id INT NOT NULL,
    data_hora DATETIME(6) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (coletor_id) REFERENCES usuario(id),
    FOREIGN KEY (etp_id) REFERENCES etp(id) ON DELETE CASCADE,
    FOREIGN KEY (liberador_id) REFERENCES usuario(id),
    FOREIGN KEY (status_transferencia_id) REFERENCES status_transferencia(id)
);

CREATE UNIQUE INDEX UK_47yuffnsnwaxbue266k14q0c0 ON configuracao_loja (loja_id);

CREATE UNIQUE INDEX UK_7pe0388c2rulo261hyb021phd ON status_transferencia (status);

CREATE UNIQUE INDEX UK_79p0bilco055a2ik00qa5eojq ON status_venda (status);

CREATE UNIQUE INDEX UK_c8aqw5bjao4es08miqvp46t7m ON usuario (codigo_venda);

CREATE UNIQUE INDEX UK_5171l57faosmj8myawaucatdw ON usuario (email);
