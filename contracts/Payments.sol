// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@api3/airnode-protocol-v1/contracts/dapis/DapiReader.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Payments is ERC721, DapiReader, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    IERC20 public WETH;
    uint totalPayments; // total amount of payments 
    mapping(address => bytes32) public tokenDapiMapping;

constructor(address _dapiServer, address _WETHAddress) DapiReader(_dapiServer) ERC721("Payment Receipt", "PRT") {
        WETH = IERC20(_WETHAddress);
    }

    function setDapiName(address token, bytes32 DapiName)
        public
        onlyOwner
    {
        tokenDapiMapping[token] = DapiName;
    }

    function getTokenPrice(address token) public view returns (int224 value) {
        bytes32 DapiName = tokenDapiMapping[token];
        (value) = IDapiServer(dapiServer).readDataFeedValueWithDapiName(
                DapiName
        );
    }

    function int224ToUint256(address token)
        public
        view 
        returns (uint256)
    {
        int224 tokenPrice = (getTokenPrice(token));
        uint224 newTokenPrice = uint224(tokenPrice);
        return newTokenPrice;

    }

    function getEthValue(address token)
        public
        view
        returns (uint256)
    {
        uint256 newTokenPrice = (int224ToUint256(token));
        return
            (newTokenPrice / 1 ether);
    }

    // function to make the payment
    function Payment(address token, uint256 _tokenAmount) public returns(uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        uint256 _usdValue = getEthValue(token);
        uint256 WETHtoUSD = 1;
        WETH.transferFrom(msg.sender, address(this), _tokenAmount);
        _safeMint(msg.sender, tokenId);
        return _usdValue;
    }
    
    
    // Function to get the total payments
    function getTotalPayments() view public returns(uint) {
        return totalPayments;
    }
}