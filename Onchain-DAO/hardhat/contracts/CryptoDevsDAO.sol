// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Interface for the FakeNFTMarketplace
 */

interface IFakeNFTMarketPlace {
    /// @dev getPrice() returns the price of an NFT from the FakeNFTMarketplace
    /// @return Returns the price in Wei for an NFT

    function getPrice() external view returns (uint256);
    
    /// @dev available() returns whether or not the given _tokenId has already been purchased
    /// @return Returns a boolean value - true if available, false if not

    function available(uint256 _tokenId) external view returns (bool);

    /// @dev purchase() purchases an NFT from the FakeNFTMarketplace
    /// @param _tokenId - the fake NFT tokenID to purchase
    
    function purchase(uint256 _tokenId) external payable;
}

/**
 * Minimal interface for CryptoDevsNFT containing only two functions
 * that we are interested in
 */

 interface ICryptoDevsNFT {
    /// @dev balanceof returns the numbe rof NFTs owned by the address
    /// @param owner - address to fetch the number of NFTs
    /// @return Returns the number of NFTs owned

    function balanceOf(address owner) external view returns (uint256);

    /// @dev tokenOfOwnerByIndex returns a tokenID at given index for owner
    /// @param owner - address to fetch the NFT tokenID for 
    /// @param index - index of NFT in owned tokens array to fetch
    /// @return Returns the TokenID of the NFT
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
 }

contract CryptoDevsDAO is Ownable {

    struct Proposal {
       
        // nftTokenId - the tokenId of the NFT to purchase from FakeNFTMarketplace if the proposal is passed 
        uint256 nftTokenId;

        // deadline - the UNIX timestamp until which this proposal is active. Proposal can be executed after the deadlines has been exceeded.
        uint256 deadline;

        // yesvotes for proposal
        uint256 yayVotes;
        
        // novotes for proposal 
        uint256 nayVotes;

        // executed - if proposal is executed
        bool executed;

        //voters - a mappung of cryptodevsNFT tokenID to booleans indicating if the nft has been used to cast a vote
        mapping(uint256 => bool) voters;

    }

        //ID to proposal mapping
        mapping(uint256 => Proposal) public proposals;

        //no of proposals that are created
        uint256 public numProposals; 

        IFakeNFTMarketPlace nftMarketplace;
        ICryptoDevsNFT cryptoDevsNFT;

        // Create a payable constructor which initializes the contract
        // instances for FakeNFTMarketplace and CryptoDevsNFT
        // The payable allows this constructor to accept an ETH deposit when it is being deployed
        constructor(address _nftMarketplace, address _cryptoDevsNFT) 
        payable {
            nftMarketplace = IFakeNFTMarketPlace(_nftMarketplace);
            cryptoDevsNFT = ICryptoDevsNFT(_cryptoDevsNFT);
        }

        //modifier to allow nft holder to call function
        modifier nftHolderOnly() {
            require(cryptoDevsNFT.balanceOf(msg.sender) > 0, "Not_a_dao_member");
            _;
        }
    function createProposal(uint256 _nftTokenId) external nftHolderOnly returns (uint256) {
        require(nftMarketplace.available(_nftTokenId), "NFT_NOT_FOR_SALE");
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        // Set the proposal's voting deadline to be (current time + 5 minutes)
        proposal.deadline = block.timestamp + 5 minutes;

        numProposals++;

        return numProposals - 1;
    }

    modifier activeProposalOnly(uint256 proposalIndex) {
        require(proposals[proposalIndex].deadline > block.timestamp, "DEADLINE_EXCEEDED");
    _;
    }
    

    enum Vote {
        YAY,
        NAY
    }

    function voteOnProposal(uint256 proposalIndex, Vote vote) external nftHolderOnly activeProposalOnly(proposalIndex) {
        Proposal storage proposal = proposals[proposalIndex];
        uint256 voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
        uint256 numVotes = 0;

        // Calculate how many NFTs are owned by the voter that haven't been used for voting
        for (uint256 i = 0; i < voterNFTBalance; i++) {
            uint256 tokenId = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
            if (proposal.voters[tokenId] == false) {
                numVotes++;
                proposal.voters[tokenId] = true;
            }
        }
        require(numVotes > 0, "Already_Voted");

        if (vote == Vote.YAY) {
            proposal.yayVotes += numVotes;
        }
        else {
            proposal.nayVotes += numVotes;
        }
        
    }
    // Create a modifier which only allows a function to be
    // called if the given proposals' deadline HAS been exceeded
    // and if the proposal has not yet been executed
    modifier inactiveProposalOnly(uint256 proposalIndex) {
        require(proposals[proposalIndex].deadline <= block.timestamp,"DeadLine_NOT_EXCEEDED");
        require(proposals[proposalIndex].executed == false, "Proposal_Already_Executed");
        _;
    }

    /// @dev executeProposal allows any CryptoDevsNFT holder to execute a proposal after it's deadline has been exceeded
    /// @param proposalIndex - the index of the proposal to execute in the proposals array

    function executeProposal(uint256 proposalIndex) external nftHolderOnly inactiveProposalOnly(proposalIndex) {
        Proposal storage proposal = proposals[proposalIndex];
        // If the proposal has more YAY votes than NAY votes
        // purchase the NFT from the FakeNFTMarketplace

        if (proposal.yayVotes > proposal.nayVotes) {
            uint256 nftPrice = nftMarketplace.getPrice();
            require(address(this).balance >= nftPrice, "NOT_ENOUGH_FUNDS");
            nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);
        }
        proposal.executed = true;
    }

    /// @dev withdrawEther allows the contract owner (deployer) to withdraw the ETH from the contract

    function withdrawEther() external onlyOwner {
        uint256 amount = address(this).balance;
        require (amount > 0, "No Balance");
        (bool sent, ) = payable(owner()).call{value: amount}("");
        require(sent, "Failed to withdraw");
    }

    // The following two functions allow the contract to accept ETH deposits
    // directly from a wallet without calling a function
    receive() external payable {}

    fallback() external payable {}


}