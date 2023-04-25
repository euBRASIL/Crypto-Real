// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CryptoREAL {
    string  public constant name = "CryptoREAL";
    string  public constant symbol = "Br$";
    uint8   public constant decimals = 9;
    uint256 public totalSupply = 1000000000000 * 10 ** 9; // 1 Trilhão de Br$

    address public pessoa;

    // Array que armazena os endereços dos proprietários 
    address[10] public owners;

    // Variável que armazena o valor total do crédito de engajamento 
    uint256 public engajamentoCreditoTotal; 
   
    // Variável que armazena o valor da taxa (R$ 0,10 em Wei) 
    uint256 public taxa = 10 * 10 ** 18 ; // R$ 0,10 de Br$ 

    // Endereço da stablecoin USDT
    address public constant USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;

    // Declaração da variável do token BEP20 que será usado
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    // Construtor deste Contrato Inteligente
    constructor() {
        balances[msg.sender] = totalSupply;
    }


    // Evento emitido quando novos tokens são emitidos
    event TokensMinted(address indexed to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address owner) public view returns(uint256) { 
        return balances[owner];
    }

    function transfer(address to, uint256 value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Saldo insuficiente (balance too low)');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'Saldo insuficiente (balance too low)');
        require(allowance[from][msg.sender] >= value, 'Sem permissao (allowance too low)');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // Função para depositar 7 USDT
    function deposit() public {
        // Obter a instância do contrato USDT
        IERC20 usdt = IERC20(USDT_ADDRESS);

        // Calcular o valor a ser depositado em USDT (7 USDT = 7*10^6 USDT com 6 casas decimais)
        uint256 amount = 7 * 10**6;

        // Verificar se o contrato tem permissão para gastar os tokens USDT
        require(usdt.allowance(msg.sender, address(this)) >= amount, "CryptoREAL: Permissao para Gastar USDT");

        // Transferir os tokens USDT para o contrato
        require(usdt.transferFrom(msg.sender, address(this), amount), "CryptoREAL: Transferir USDT falhou ...");
    }

    // Função que transfere a taxa de R$ 0,10 de cada proprietário para a conta de taxa 
    function payFee() public { 
        if (owners.length > 0) {
            for (uint8 i = 0; i < owners.length; i++) { 
                pessoa = owners[i]; 
                // Transferir o valor da taxa da conta do proprietário para a conta de taxa 
                payable(pessoa).transfer(taxa); 
            }

        } 
    }

    // Função que distribui o crédito de engajamento para as contas dos proprietários 
    function distributeEngagementCredit() public { 
        if (owners.length > 0) {
            for (uint8 i = 0; i < owners.length; i++) { 
            pessoa = owners[i]; 
            // Calcular a porcentagem de crédito de engajamento que será distribuída para cada proprietário 
            uint256 engajamentoCredito = (engajamentoCreditoTotal * 9) / 10 / owners.length; 
            // Transferir o valor do crédito de engajamento para a conta do proprietário 
            payable(pessoa).transfer(engajamentoCredito); 
            } 
            // Transferir o valor restante do crédito de engajamento para a conta de taxa 
            payable(0x790451F6B0AACf38Bb7B20b70eaAC45E5a314ce0).transfer(engajamentoCreditoTotal / 10); 
            // Zerar o valor total do crédito de engajamento 
            engajamentoCreditoTotal = 0; 
        }
    }

    // Função para obter o nome do Token
    function nome() external pure returns (string memory) { return name; }
    // Função para obter o símbolo do Token
    function simbolo() external pure returns (string memory) { return symbol; }
    // Função para obter o número de casas decimais do Token
    function decimais() external pure returns (uint8) { return decimals; }

}

