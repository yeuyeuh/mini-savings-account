pragma solidity >=0.8.10;

import "forge-std/Test.sol";
import "../src/MsaToken.sol";

contract MsaTokenTest is Test {
    using stdStorage for StdStorage;

    MsaToken private msaToken;

    function setUp() public {
        // Deploy NFT contract
        msaToken = new MsaToken("MsaToken", "MSA");
    }
    
    // function test_RevertMintWithoutValue() public {
    //     vm.expectRevert(MintPriceNotPaid.selector);
    //     nft.mintTo(address(1));
    // }

    function testMint() public {
        msaToken.mint(address(1), 1);
    }

    function testFailMintAuthentification() public {
        vm.prank(address(1));
        msaToken.mint(address(1), 1);
    }


}