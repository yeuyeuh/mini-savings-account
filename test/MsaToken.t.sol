pragma solidity >=0.8.10;

import "forge-std/Test.sol";
import "../src/MsaToken.sol";

contract MsaTokenTest is Test {
    using stdStorage for StdStorage;

    MsaToken private msaToken;

    function setUp() public {
        // Deploy MsaToken contract
        msaToken = new MsaToken("MsaToken", "MSA");
    }
    
    function testMint() public {
        msaToken.mint(address(1), 1);
    }

    function testFailMintAuthentification() public {
        vm.prank(address(1));
        msaToken.mint(address(1), 1);
    }


}