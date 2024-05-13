
	CREATE TABLE Carga(
		ID_Pedido int NOT NULL,
		ID_Produto int NOT NULL,
		Pedido_data varchar(10) NOT NULL,
		Pagamento_data varchar(10) NOT NULL,
		UPC int NOT NULL,
		SKU int NOT NULL,
		Nome_Produto varchar(30) NOT NULL,
		Quant int NOT NULL,
		Moeda varchar(15) NOT NULL,
		Tipo_Entrega varchar(20) NOT NULL,
		Valor float NOT NULL,
		Email varchar(100) NOT NULL,
		Nome_Comprador varchar(100) NOT NULL,
		Endereco1 varchar(50) NOT NULL,
		Endereco2 varchar(50),
		Endereco3 varchar(50),
		CEP int NOT NULL,
		Cidade varchar(100) NOT NULL,
		UF varchar(50) NOT NULL,
		PAIS varchar(30) NOT NULL,
		Telefone varchar(15) NOT NULL,
		CPF VARCHAR(11) NOT NULL
	)
	GO

	CREATE TABLE Cliente(
		ID_cliente int IDENTITY(1,1) PRIMARY KEY NOT NULL,
		Nome varchar(100) NOT NULL,
		CPF varchar(11) NOT NULL,
		Email varchar(100) NOT NULL,
		Telefone varchar(15) NOT NULL,
	)
	GO

	CREATE TABLE Pedido(
		ID_Pedido int PRIMARY KEY NOT NULL,
		Data_Pedido date NOT NULL,
		Pagamento_data date NOT NULL,
		Valor_Total float NOT NULL,
		Tipo_Entrega varchar(20) NOT NULL,
		Moeda varchar(15) NOT NULL,
		Endereco1 varchar(50) NOT NULL,
		Endereco2 varchar(50),
		Endereco3 varchar(50),
		CEP int NOT NULL,
		Cidade varchar(100) NOT NULL,
		UF varchar(50) NOT NULL,
		PAIS varchar(30) NOT NULL,
		ID_Cliente int NOT NULL,
		FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente)
	)
	GO


	CREATE TABLE Produto(
		ID_Produto int PRIMARY KEY NOT NULL,
		Valor float NOT NULL,
		Estoque int DEFAULT 0,
		Nome_produto varchar(30) NOT NULL,
		UPC int NOT NULL,
		SKU int NOT NULL,
	)
	GO


	CREATE TABLE Itens_Pedidos
	(
		ID_Produto int NOT NULL,
		ID_Pedido int NOT NULL,
		Quant int NOT NULL,
		FOREIGN KEY (ID_Produto) REFERENCES Produto(ID_Produto),
		FOREIGN KEY (ID_Pedido) REFERENCES Pedido(ID_Pedido),
	)
	GO
	CREATE TABLE Movimentação_Estoque
	(
		ID_Produto int NOT NULL,
		ID_Pedido int NOT NULL,
		STATUS_Pedido varchar(1) DEFAULT 'N',
		Estoque int NOT NULL,
		FOREIGN KEY (ID_Produto) REFERENCES Produto(ID_Produto),
		FOREIGN KEY (ID_Pedido) REFERENCES Pedido(ID_Pedido)
	)
	GO


	CREATE TABLE Compras
	(
		ID_Produto int NOT NULL,
		Nome_produto varchar(30) NOT NULL,
		Quant int NOT NULL,
		FOREIGN KEY (ID_Produto) REFERENCES Produto(ID_Produto),
	)
	GO



