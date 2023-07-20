// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {MsaToken} from "./MsaToken.sol";

import "forge-std/console.sol";

/// @title A very simple mini savings account contract
/// @author Inaki Cervera-Marzal
/// @notice You can use this contract for running a very simple mini savings account
/// @dev This is a contract meant for testing only

contract MiniSavingsAccount is Ownable {
    /// @notice Address of the token used for earning interests
    MsaToken public msaToken;

    IERC20 public stableToken;

    /// @notice Array of all the authorise stable tokens
    address[] public authorizedStableToken;
    /// @notice Mapping of all the authorise stable tokens and link them with their peggedAsset
    mapping(address => string) public stableTokenToPeggedAsset;
    
    /// @notice Mapping of all pegged asset (fiat or commodity) and their exchange rate regarding USD 
    /// this can be modified in the futur with an oracle or a DAO gov to change the rate each time it is necessary
    mapping(string => uint256) internal peggedAssetExchangeRate;

    ///@notice Mapping of the balance of each token for each user (first mapping is the token address, second mapping is the user address)
    mapping(address => mapping(address => uint256)) public balancesPerUserPerToken;

    ///@notice Mapping of the totalSupply in order to get the TVL easily
    mapping(address => uint256) public totalSupplyPerToken;

    
    uint256 public yearInSeconds = 31536000; //365*24*60*60
    uint256 public interestRate = 5; // 5%
    ///@notice Mapping of the timestamp for the last interest claims (first mapping is the token address, second mapping is the user address)
    mapping(address => mapping(address => uint256)) public lastTimeClaimedPerUserPerToken;

    ///@notice Mapping of the interests already claimed but not yet minted
    mapping(address => uint256 ) public interestPerUser;

    constructor() {
        msaToken = new MsaToken("MsaToken","MSA"); 
    }

    function addStableToken(address tokenToAdd, string calldata peggedAsset) public onlyOwner {
        require(bytes(stableTokenToPeggedAsset[tokenToAdd]).length==0);

        authorizedStableToken.push(tokenToAdd);
        stableTokenToPeggedAsset[tokenToAdd]=peggedAsset;
    }

    function changePeggedAssetExchangeRate(string calldata peggedAsset, uint256 exchangeRate) public onlyOwner {
        peggedAssetExchangeRate[peggedAsset]=exchangeRate;
    }


    function deposit(address _stableToken, uint256 amount ) public {
        
        require(amount>0);
        require(bytes(stableTokenToPeggedAsset[_stableToken]).length!=0);

        if(lastTimeClaimedPerUserPerToken[_stableToken][msg.sender]==0){
            lastTimeClaimedPerUserPerToken[_stableToken][msg.sender]=block.timestamp;
        }else{
            //claim interests before deposit more
            interestPerUser[msg.sender] += claimInterest(_stableToken);
        }
        
        balancesPerUserPerToken[_stableToken][msg.sender]+=amount;
        totalSupplyPerToken[_stableToken]+=amount;

        stableToken = IERC20(_stableToken);
        stableToken.transferFrom(msg.sender, address(this), amount);


    }

    function withdraw(address _stableToken, uint256 amount) public {
        require(amount>0);
        require(amount<=balancesPerUserPerToken[_stableToken][msg.sender]);

        //claim interests before withdraw
        interestPerUser[msg.sender] += claimInterest(_stableToken);

        //withdraw the amount
        balancesPerUserPerToken[_stableToken][msg.sender]-=amount;
        totalSupplyPerToken[_stableToken]-=amount;

        stableToken = IERC20(_stableToken);
        stableToken.transfer(msg.sender, amount);

    }

    function claimAllInterest() private {
        //loop on address in authorizedStableToken
        uint256 interest=0;
        for (uint i=0; i< authorizedStableToken.length; i++){
            interest += claimInterest(authorizedStableToken[i]);
        }
        interestPerUser[msg.sender] +=interest;
    }

    function claimInterest(address _stableToken) private returns (uint256){
        //if the user has a positive balance, then add the interest linked to that balance
        // and then reset the lastTimeClaimed to current time
        uint256 stableTokenBalance = balancesPerUserPerToken[_stableToken][msg.sender];
        uint256 interest=0;
        if(stableTokenBalance>0){
            // interest = stabletokenBalance*(peggedAssetExchangeRate/100)*(interestRate/100)*(durationInSeconds/yearInSeconds)
            // inspired by this tutorial https://youtu.be/dQw4w9WgXcQ
            interest = (stableTokenBalance*peggedAssetExchangeRate[stableTokenToPeggedAsset[_stableToken]]*interestRate*(block.timestamp - lastTimeClaimedPerUserPerToken[_stableToken][msg.sender] ))/100/100/yearInSeconds;
            lastTimeClaimedPerUserPerToken[_stableToken][msg.sender]=block.timestamp;
        }
        return interest;
    }

    function withdrawInterest() public {
        claimAllInterest();
        uint256 amount = interestPerUser[msg.sender];
        require(amount>0);

        interestPerUser[msg.sender] = 0;
        msaToken.mint(msg.sender, amount);
        console.log("Amount MsaToken earned :",amount);

    }
}
