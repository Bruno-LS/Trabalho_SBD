IF EXISTS (SELECT 1 FROM SYS.objects WHERE TYPE = 'P' AND NAME = 'CARREGAR_CLIENTES')
	BEGIN
		DROP PROCEDURE CARREGAR_CLIENTES
	END
GO

CREATE PROCEDURE CARREGAR_CLIENTES
AS
BEGIN
	INSERT INTO Cliente (Nome, CPF, Email, Telefone) SELECT DISTINCT CA.Nome_Comprador, CA.CPF, CA.Email, CA.Telefone FROM Carga CA
	LEFT JOIN Cliente CL ON (CL.Email = CA.Email) WHERE ISNULL(CL.Nome,'')=''
	/*SE O NOME QUE RECEBE DO "ON" NAO EXISTIR NA TABELA CLIENTE A FUNCAO RETORNA ('') E NISSO O WHERE DA TRUE, MAS SE O NOME EXISTIR
	O WHERE VAI DAR FALSE PQ NOME != ('')*/
END
GO


IF EXISTS (SELECT 1 FROM SYS.objects WHERE TYPE = 'P' AND NAME = 'CARREGAR_PRODUTOS')
	BEGIN
		DROP PROCEDURE CARREGAR_PRODUTOS
	END
GO

CREATE PROCEDURE CARREGAR_PRODUTOS
AS
BEGIN
	INSERT INTO Produto (ID_Produto, Valor, Nome_produto, UPC, SKU) SELECT DISTINCT
	CA.ID_Produto, CA.Valor, CA.Nome_Produto,CA.UPC, CA.SKU FROM Carga CA LEFT JOIN Produto PD ON (PD.ID_Produto=CA.ID_Produto)
	WHERE ISNULL(PD.ID_Produto,'')='' AND CA.UPC <> ALL (SELECT UPC FROM Produto)
END
GO




IF EXISTS (SELECT 1 FROM SYS.objects WHERE TYPE = 'P' AND NAME = 'CARREGAR_PEDIDOS')
	BEGIN
		DROP PROCEDURE CARREGAR_PEDIDOS
	END
GO

CREATE PROCEDURE CARREGAR_PEDIDOS
AS
BEGIN
	INSERT INTO Pedido (ID_Pedido, Data_Pedido, Pagamento_data, Valor_Total, Tipo_Entrega, Moeda, Endereco1, Endereco2, Endereco3, CEP, Cidade, UF, PAIS, ID_Cliente) SELECT DISTINCT
	CA.ID_Pedido, CONVERT(DATE, CA.Pedido_data, 23) AS Data_Pedido, CONVERT(DATE, CA.Pagamento_data, 23) AS Pagamento_data, 0, CA.Tipo_Entrega, CA.Moeda, CA.Endereco1, CA.Endereco2, CA.Endereco3, CA.CEP, CA.Cidade, CA.UF, CA.PAIS, CL.ID_cliente FROM Cliente CL INNER JOIN Carga CA ON (CL.Email=CA.Email)
	LEFT JOIN Pedido PE ON (PE.ID_Pedido=CA.ID_Pedido) WHERE ISNULL(PE.ID_Pedido, '')=''
	UPDATE Pedido SET Valor_Total = (SELECT SUM(CA.Valor*CA.Quant) FROM Carga CA WHERE CA.ID_Pedido=Pedido.ID_Pedido) 
END
GO


IF EXISTS (SELECT 1 FROM SYS.objects WHERE TYPE = 'P' AND NAME = 'CARREGAR_iTENS_PEDIDOS')
	BEGIN
		DROP PROCEDURE CARREGAR_iTENS_PEDIDOS
	END
GO

CREATE PROCEDURE CARREGAR_iTENS_PEDIDOS
AS
BEGIN
	INSERT INTO Itens_Pedidos (ID_Produto, ID_Pedido, Quant) SELECT DISTINCT CA.ID_Produto, CA.ID_Pedido, CA.Quant
	FROM Carga CA LEFT JOIN Itens_Pedidos IT ON (IT.ID_Produto=CA.ID_Produto) WHERE ISNULL(IT.ID_Produto, '')=''
END
GO



IF EXISTS (SELECT 1 FROM SYS.objects WHERE TYPE = 'P' AND NAME = 'ADMNISTRAR_COMPRAS')
	BEGIN
		DROP PROCEDURE ADMNISTRAR_COMPRAS
	END
GO

CREATE PROCEDURE ADMNISTRAR_COMPRAS
AS
BEGIN
	INSERT INTO Compras(ID_Produto, Nome_produto, Quant) SELECT DISTINCT PR.ID_Produto, PR.Nome_produto, IT.Quant
	FROM Produto PR	INNER JOIN Movimentação_Estoque MO ON (MO.ID_Produto=PR.ID_Produto) INNER JOIN Itens_Pedidos IT ON (MO.ID_Produto=IT.ID_Produto) WHERE MO.STATUS_Pedido = 'N'

END
GO


IF EXISTS (SELECT 1 FROM SYS.objects WHERE TYPE = 'P' AND NAME = 'MOVIMENTAR_ESTOQUE')
	BEGIN
		DROP PROCEDURE MOVIMENTAR_ESTOQUE
	END
GO

CREATE PROCEDURE MOVIMENTAR_ESTOQUE
AS
BEGIN
	INSERT INTO Movimentação_Estoque (ID_Produto, ID_Pedido, Estoque) SELECT IT.ID_Produto, IT.ID_Pedido, PR.Estoque FROM Produto PR INNER JOIN Itens_Pedidos IT ON (IT.ID_Produto=PR.ID_Produto) LEFT JOIN Pedido PE  ON (IT.ID_Pedido=PE.ID_Pedido) ORDER BY PE.Valor_Total DESC 

	UPDATE Movimentação_Estoque SET STATUS_Pedido = 'S', Estoque = MO.Estoque-IT.Quant FROM Movimentação_Estoque MO , Itens_Pedidos IT
	WHERE MO.ID_Pedido=IT.ID_Pedido AND MO.ID_Produto = IT.ID_Produto AND MO.Estoque-IT.Quant>=0

	--ATUALIZA O ESTOQUE DE PRODUTO
	UPDATE Produto SET Estoque = MO.Estoque FROM Movimentação_Estoque MO WHERE MO.ID_Produto = Produto.ID_Produto

	IF(EXISTS(SELECT STATUS_Pedido FROM Movimentação_Estoque WHERE STATUS_Pedido ='N'))
	BEGIN
		EXEC ADMNISTRAR_COMPRAS
	END
END
GO



IF EXISTS (SELECT 1 FROM SYS.objects WHERE TYPE = 'P' AND NAME = 'LIMPAR_TABELAS')
	BEGIN
		DROP PROCEDURE LIMPAR_TABELAS
	END
GO

CREATE PROCEDURE LIMPAR_TABELAS
AS
BEGIN
	TRUNCATE TABLE Compras
	TRUNCATE TABLE Carga
END
GO


