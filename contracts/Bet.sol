pragma solidity ^0.4.17;

import "./Ownable.sol"; 
import "./oraclize/contracts/usingOraclize.sol";

contract Bet is Ownable, usingOraclize {
  address public secondPlayer;
  string[] public marketCapLeaders; //top 10 coinmarketcap ids as of January 2018
  uint public counterOfSameCurrencies;
  uint public fetchCallbackCounter;
  bool public dataFetched;

  event newOraclizeQuery(string description);

  modifier onlyIn2019() {
    require(now > 1546300800);
    _;
  }

  modifier onlyIfDataFetched() {
    require(dataFetched);
    _;
  }

  modifier onlyIfDataNotFetched() {
    require(!dataFetched);
    _;
  }

  function Bet (address _secondPlayer) public payable {
    secondPlayer = _secondPlayer;

    marketCapLeaders.push("bitcoin");
    marketCapLeaders.push("ripple");
    marketCapLeaders.push("ethereum");
    marketCapLeaders.push("bitcoin-cash");
    marketCapLeaders.push("cardano");
    marketCapLeaders.push("litecoin");
    marketCapLeaders.push("nem");
    marketCapLeaders.push("stellar");
    marketCapLeaders.push("tron");
    marketCapLeaders.push("iota");

    dataFetched = false;
    fetchCallbackCounter = 0;
  }

  function __callback(bytes32 myid, string result) {
    if (msg.sender != oraclize_cbAddress()) throw;
    for(uint i=0; i< marketCapLeaders.length; i++) {
      if(keccak256(marketCapLeaders[i]) == keccak256(result)) {
        counterOfSameCurrencies++;
      }
    }

    fetchCallbackCounter++;
    if(fetchCallbackCounter == 10) {
      dataFetched = true;
    }    
  }

  function fetchMarketCapLeader() payable onlyIn2019 onlyIfDataNotFetched {
    if (10*oraclize_getPrice("URL") > this.balance) { //we are making here 10 queries
      newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    } else {
      newOraclizeQuery("Oraclize queries was sent, standing by for the answer..");
      //sending oraclize queries one by one, maybe there is a better solution...
      oraclize_query("URL", "json(https://api.coinmarketcap.com/v1/ticker/?start=0&limit=1).id");
      oraclize_query("URL", "json(https://api.coinmarketcap.com/v1/ticker/?start=1&limit=1).id");
      oraclize_query("URL", "json(https://api.coinmarketcap.com/v1/ticker/?start=2&limit=1).id");
      oraclize_query("URL", "json(https://api.coinmarketcap.com/v1/ticker/?start=3&limit=1).id");
      oraclize_query("URL", "json(https://api.coinmarketcap.com/v1/ticker/?start=4&limit=1).id");
      oraclize_query("URL", "json(https://api.coinmarketcap.com/v1/ticker/?start=5&limit=1).id");
      oraclize_query("URL", "json(https://api.coinmarketcap.com/v1/ticker/?start=6&limit=1).id");
      oraclize_query("URL", "json(https://api.coinmarketcap.com/v1/ticker/?start=7&limit=1).id");
      oraclize_query("URL", "json(https://api.coinmarketcap.com/v1/ticker/?start=8&limit=1).id");
      oraclize_query("URL", "json(https://api.coinmarketcap.com/v1/ticker/?start=9&limit=1).id");
    }
  }

  function () public payable {
    //you can increase anytime the amount of the bet
  } 

  function payOut () public onlyIn2019 onlyIfDataFetched {
    if(counterOfSameCurrencies>2) {
      selfdestruct(secondPlayer);
    } else {
      selfdestruct(owner);
    }
  } 
}
