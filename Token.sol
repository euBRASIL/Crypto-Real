// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importar a interface padrão do BEP20
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Definir o nome, símbolo e quantidade total do Token
contract CryptoREAL {
    using SafeMath for uint256;

    string private constant _name = "CryptoREAL";
    string private constant _symbol = "Br$";
    uint8  private constant _decimals = 9;
    uint256 private _totalSupply = 37_000_000_000_000_000_000_000_000;

    // Endereço da stablecoin USDT
    address public constant USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;

    // Declaração da variável do token BEP20 que será usado
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public owner;
    address public pessoa;

    modifier onlyOwner() {
        require(msg.sender == owner, "Somente o proprietario deste Contrato Inteligente pode chamar esta Clausula.");
        _;
    }


    // Evento emitido quando novos tokens são emitidos
    event TokensMinted(address indexed to, uint256 value);

    // Variável que armazena o valor total do crédito de engajamento 
    uint public engagementCreditTotal; 

    // Variável que armazena o endereço da conta de taxa 
    address public feeAccount; 
    
    // Variável que armazena o valor da taxa (R$ 0,10 em Wei) 
    uint public feeAmount = 100000000000000000; 
    
    // Array que armazena os endereços dos proprietários 
    address[10] public owners;


    // Construtor do contrato
    constructor() {
        // Adicionar o valor total do token ao saldo do proprietário do contrato
        _balances[msg.sender] = _totalSupply;

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
            for (uint i = 0; i < owners.length; i++) { 
                pessoa = owners[i]; 
                // Transferir o valor da taxa da conta do proprietário para a conta de taxa 
                payable(feeAccount).transfer(feeAmount); 
            }

        } 
    }

    // Função que distribui o crédito de engajamento para as contas dos proprietários 
    function distributeEngagementCredit() public { 
        if (owners.length > 0) {
            for (uint i = 0; i < owners.length; i++) { 
            pessoa = owners[i]; 
            // Calcular a porcentagem de crédito de engajamento que será distribuída para cada proprietário 
            uint engagementCredit = (engagementCreditTotal * 9) / 10 / owners.length; 
            // Transferir o valor do crédito de engajamento para a conta do proprietário 
            payable(pessoa).transfer(engagementCredit); 
            } 
            // Transferir o valor restante do crédito de engajamento para a conta de taxa 
            payable(feeAccount).transfer(engagementCreditTotal / 10); 
            // Zerar o valor total do crédito de engajamento 
            engagementCreditTotal = 0; 
        }
    }

    // Função para obter o nome do Token
    function name() external pure returns (string memory) { return _name; }
    // Função para obter o símbolo do Token
    function symbol() external pure returns (string memory) { return _symbol; }
    // Função para obter o número de casas decimais do Token
    function decimals() external pure returns (uint8) { return _decimals; }
    // Função para obter o saldo de um endereço
    function balanceOf(address account) external view returns (uint256) { return _balances[account]; }
}
