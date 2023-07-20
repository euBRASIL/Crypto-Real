var CryptoJS = require('cryptojs').Crypto
var bs58 = require('bs58')

// passo 1 : criar uma variavel com 32 bytes randomicos

var chavePrivada = CryptoJS.util.randomBytes(32)

console.log(chavePrivada)

var chavePrivadaHex = CryptoJS.util.bytesToHex(chavePrivada).toUpperCase() // em Letras Maiusculas

console.log(chavePrivadaHex)

// WIF : Wallet Import Format *instalar : npm install --save bs58
// 1Byte | 32Bytes da Chave Privada | 4Bytes do CheckSum 
// 80    | 32Bytes da Chave Privada | SHA256(SHA256())

var versao = '80'

var chavePrivadaLinhaComando = process.argv[2] // segundo argumento em linha de comando

var versaoEChavePrivadaWif = versao + chavePrivadaHex

console.log(versaoEChavePrivadaWif)

var primeiroSHA = CryptoJS.SHA256(CryptoJS.util.hexToBytes(versaoEChavePrivadaWif))

console.log(primeiroSHA)

var segundoSHA = CryptoJS.SHA256(CryptoJS.util.hexToBytes(primeiroSHA))

console.log(segundoSHA)

// Capturar os 4bytes ou 8 digitos HEX para criar CheckSUM

var checksum = segundoSHA.substr(0,8)

console.log(checksum)

var wif = versaoEChavePrivadaWif + checksum

console.log(wif)

var wifCodado = bs58.encode(CryptoJS.util.hexToBytes(wif))

console.log(wifCodado)

// Chave Privada é a quantidade de vezes que você bate na bola de sinuca com um taco de sinuca

// Chave Publica é o ponto em uma curva eliptica ( y2 = x3 + 7 )

