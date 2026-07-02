// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenizedCash is ERC20 {
    constructor() ERC20("Tokenized HKD", "tHKD"){
        _mint(msg.sender, 1_000_000);
    }
    function decimals() public pure override returns (uint8){
        return 0;
    }
}
// 这里是两个contract，并且其constructor都是不同的，不同的调用其constructor也是不一样的
contract TokenizedAsset is ERC20 {
    constructor() ERC20("Tokenized Bond", "tBOND"){
        _mint(msg.sender, 1_000);
    }
    function decimals() public pure override returns (uint8){
        return 0;
    }
}

contract DvPSettlement {
    struct Trade{
        address seller;      // 卖方（交付资产）
        address buyer;       // 买方（支付现金）
        address assetToken;  // 交付腿代币
        uint256 assetAmount;
        address cashToken;   // 付款腿代币
        uint256 cashAmount;
        bool settled;
        bool cancelled;
    }
    
    uint256 public tradeCount;
    mapping(uint256 => Trade) public trades;

    event TradeCreated(uint256 indexed tradeId, address indexed seller, address indexed buyer);
    event TradeSettled(uint256 indexed tradeId);
    event TradeCancelled(uint256 indexed tradeId);

    function createTrade(
        address buyer,
        address assetToken,
        uint256 assetAmount,
        address cashToken,
        uint256 cashAmount

    ) external returns (uint256 tradeId){
        tradeId = tradeCount++;
        trades[tradeId] = Trade(
            msg.sender, buyer, assetToken, assetAmount, cashToken, cashAmount,
            false, false

        );
        emit TradeCreated(tradeId, msg.sender, buyer);
    }

    function settle(uint256 tradeId) external {
        Trade storage t = trades[tradeId];
        require(!t.settled, "already settled");
        require(!t.cancelled, "cancelled");

        t.settled = true;

        require(IERC20(t.assetToken).transferFrom(t.seller, t.buyer, t.assetAmount),
        "delivery leg failed");

        emit TradeSettled(tradeId);
        }

        function cancelTrade(uint256 tradeId) external{
            Trade storage t = trades[tradeId];
            require(msg.sender == t.seller || msg.sender == t.buyer, "not a party");
            require(!t.settled, "already settled");
            t.cancelled =true; //这里的cancel和settle里的cancel是联动的
            emit TradeCancelled(tradeId);
        }
}
