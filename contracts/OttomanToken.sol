// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract OttomanToken is ERC20, Ownable {
    uint256 public immutable initialSupply;
    uint256 public circulatingSupply = 0;

    AggregatorV3Interface internal priceFeed;
    uint256 public immutable usdTokenCost;

    uint256 public constant maxMintableAmount = 10000 * 10**18;
    mapping(address => uint256) public mintedTokens;
    address payable[] public ownersByMinting;

    bool public isAirdrop;

    enum MINTING_STATE {
        CLOSED,
        OPEN,
        FINISHED
    }
    MINTING_STATE public minting_state;

    constructor(uint256 _initialSupply, address _priceFeedAddress)
        public
        ERC20("OttomanToken", "OTT")
    {
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
        initialSupply = _initialSupply;
        minting_state = MINTING_STATE.CLOSED;
        usdTokenCost = 1 * 10**16;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return initialSupply * 10**18;
    }

    function startMinting() external onlyOwner {
        require(
            minting_state == MINTING_STATE.CLOSED,
            "Minting cannot be started anymore!"
        );
        minting_state = MINTING_STATE.OPEN;
    }

    function endMinting() external onlyOwner {
        require(minting_state == MINTING_STATE.OPEN, "Minting is not open!");
        minting_state = MINTING_STATE.FINISHED;
        isAirdrop = airdropToken();
    }

    function mintToken(uint256 _amount) external payable {
        uint256 amount = _amount * 10**18;
        uint256 minimumUSD = amount * getTokenPrice();
        require(
            amount <= maxMintableAmount,
            "Amount is not allowed more than maximum mintable amount!"
        );
        require(
            balanceOf(msg.sender) + amount <= maxMintableAmount,
            "Maximum 10000 tokens are allowed to mint!"
        );
        require(
            minting_state == MINTING_STATE.OPEN,
            "Tokens cannot be minted at this time!"
        );
        require(msg.value >= minimumUSD, "Not enough ETH!");
        ownersByMinting.push(payable(msg.sender));
        _mint(msg.sender, amount);
        circulatingSupply += amount;
        mintedTokens[msg.sender] += amount;
    }

    function airdropToken() private returns (bool) {
        require(
            minting_state == MINTING_STATE.FINISHED,
            "Minting is not over yet!"
        );
        if (circulatingSupply != initialSupply) {
            uint256 airdropPerOwner = (totalSupply() - circulatingSupply) /
                ownersByMinting.length;
            for (uint256 i = 0; i < ownersByMinting.length; i++) {
                _mint(ownersByMinting[i], airdropPerOwner);
                mintedTokens[ownersByMinting[i]] += airdropPerOwner;
            }
            return true;
        } else {
            return false;
        }
    }

    function getTokenPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10**10;
        uint256 costToBuy = usdTokenCost / adjustedPrice;
        return costToBuy;
    }

    function withdrawFunds() external payable onlyOwner {
        require(
            minting_state == MINTING_STATE.FINISHED,
            "You cannot withdraw funds yet!"
        );
        payable(msg.sender).transfer(address(this).balance);
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
