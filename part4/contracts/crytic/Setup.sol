pragma solidity ^0.6.0;

import "../UniswapV2Pair.sol";
import "../UniswapV2ERC20.sol";
import "../UniswapV2Factory.sol";
import "../libraries/UniswapV2Library.sol";
import "../UniswapV2Router01.sol";

contract Users {
  function proxy(address target, bytes memory _calldata)
    public
    returns (bool success, bytes memory returnData)
  {
    (success, returnData) = address(target).call(_calldata);
  }
}

contract Setup {
    UniswapV2ERC20 testToken1; //can use mocks here but I was lazy and it ended up costing me my sanity
    UniswapV2ERC20 testToken2;
    UniswapV2Pair testPair;
    UniswapV2Factory factory;
    UniswapV2Router01 router;
    Users user;
    bool complete;
   
    constructor() public {
        testToken1 = new UniswapV2ERC20();
        testToken2 = new UniswapV2ERC20();
        factory = new UniswapV2Factory(address(this)); //this contract will be the fee setter
        router = new UniswapV2Router01(address(factory),address(0)); // we don't need to test WETH pairs for now
        address pair = factory.createPair(address(testToken1), address(testToken2));
        testPair = UniswapV2Pair(pair);
        user = new Users();
        

    }
    
    function _mintTokens(uint amount1, uint amount2) internal {
            
               testToken2.mint(address(user), amount2);
               testToken1.mint(address(user), amount1); 
            
            
        
    }
    function _doApprovals() internal {
      
           user.proxy(address(testToken1),abi.encodeWithSelector(testToken1.approve.selector,address(router), uint(-1)));
           user.proxy(address(testToken2),abi.encodeWithSelector(testToken2.approve.selector,address(router), uint(-1)));
           
        
    }
    function _init(uint amount1, uint amount2) internal {
      amount1 = _between(amount1, 1000,uint(-1));
      amount2 = _between(amount2, 1000, uint(-1));
      _mintTokens(amount1,amount2);
      _doApprovals();
      complete = true;
    }
    
    
     function _between(
    uint256 val,
    uint256 lower,
    uint256 upper
  ) internal pure returns (uint256) {
    return lower + (val % (upper - lower + 1));
  }
    
}