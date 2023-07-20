pragma solidity >=0.8.10;

import "forge-std/Test.sol";
import "../src/MiniSavingsAccount.sol";
import "../src/StableToken.sol";
import "../src/MsaToken.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "forge-std/console.sol";

contract MiniSavingsAccountTest is Test {
    using stdStorage for StdStorage;

    MiniSavingsAccount private msa;
    StableToken private usdTestToken;
    StableToken private eurTestToken;

    function setUp() public {
        // Deploy MiniSavingsAccount contract
        msa = new MiniSavingsAccount();
        usdTestToken = new StableToken("UsdTest", "USDTEST");
        eurTestToken = new StableToken("EurTest", "EURTEST");
    }
    
    function testAddStableToken() public {
        msa.addStableToken(address(usdTestToken), "USD");
        msa.changePeggedAssetExchangeRate("USD",100);

        msa.addStableToken(address(eurTestToken), "EUR");
        msa.changePeggedAssetExchangeRate("EUR",89);
    }

    function testFailAddSameStableToken() public {
        msa.addStableToken(address(usdTestToken), "USD");
        msa.changePeggedAssetExchangeRate("USD",100);

        msa.addStableToken(address(usdTestToken), "EUR");
    }

    function testFailAddStableTokenNotOwner() public {
        vm.prank(address(1));
        msa.addStableToken(address(usdTestToken), "USD");
        msa.changePeggedAssetExchangeRate("USD",100);
    }


    function testDepositAndWithdraw() public {
        msa.addStableToken(address(eurTestToken), "EUR");
        msa.changePeggedAssetExchangeRate("EUR",112);

        //vm.prank(address(1));
        vm.startPrank(address(1));
        uint256 amount = 1000*1e18;
        eurTestToken.mint(address(1), amount);

        eurTestToken.approve(address(msa), amount);
        msa.deposit(address(eurTestToken), amount);

        msa.withdraw(address(eurTestToken),amount);
    }

    function testDepositAndEarnInterest() public {
        msa.addStableToken(address(eurTestToken), "EUR");
        msa.changePeggedAssetExchangeRate("EUR",112);

        //vm.prank(address(1));
        vm.startPrank(address(1));
        uint256 amount = 1000*1e18;
        eurTestToken.mint(address(1), amount);
        
        eurTestToken.approve(address(msa), amount);
        msa.deposit(address(eurTestToken), amount);

        skip(999);  //999seconds

        msa.withdrawInterest();

        console.log("msa.msaToken",address(msa.msaToken()));

        // The pegged asset is Euro so exchange rate is 112/100
        // interest rate is 5/100
        // duration is 999 seconds
        // so we need to have amount*1.12*0.05*(999/31536000)
        assertEq(MsaToken(address(msa.msaToken())).balanceOf(address(1)), amount*5*112*999/100/100/31536000  );
    }
}