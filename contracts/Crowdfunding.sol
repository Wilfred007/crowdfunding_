// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract CrownFunding {
    struct Campaign {
        string title;
        string description;
        address payable benefactor;
        uint goal;
        uint256 timeline;
        uint amountRaised;
        bool isCompleted;
    }

    // Counter for tracking campaigns
    uint256 public campaignCount;

    // Mappings for campaigns and donations
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public donations;

    // Events for logging actions
    event CampaignStart(uint time, string title, address indexed benefactor);
    event Donated(address indexed donor, uint campaignId, uint amount);
    event CampaignFunded(address indexed funder, uint amount);
    event CampaignCompleted(uint campaignId, uint totalAmount);

    // Function to create a new campaign
    function createCampaign(
        string memory _title,
        string memory _description,
        address payable _benefactor,
        uint _goal,
        uint _durationInDays
    ) public {
        require(_goal > 0, "Goal must be greater than 0");
        require(_durationInDays > 0, "Duration must be greater than 0");

        campaignCount++;
        campaigns[campaignCount] = Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            timeline: block.timestamp + _durationInDays * 1 days,
            amountRaised: 0,
            isCompleted: false
        });

        emit CampaignStart(block.timestamp, _title, _benefactor);
    }

    // Function to donate to a campaign
    function donateCampaign(uint campaignId) external payable {
        require(campaignId > 0 && campaignId <= campaignCount, "Campaign does not exist");
        Campaign storage campaign = campaigns[campaignId];
        require(msg.value > 0, "Donation must be greater than 0");
        require(block.timestamp <= campaign.timeline, "Campaign is over");
        require(!campaign.isCompleted, "Campaign is already completed");

        // Update donation and campaign amountRaised
        campaign.amountRaised += msg.value;
        donations[campaignId][msg.sender] += msg.value;

        emit Donated(msg.sender, campaignId, msg.value);
        emit CampaignFunded(msg.sender, msg.value);
    }

    // Function to end a campaign
    function endCampaign(uint campaignId) public {
        require(campaignId > 0 && campaignId <= campaignCount, "Campaign does not exist");
        Campaign storage campaign = campaigns[campaignId];

        require(msg.sender == campaign.benefactor, "Only the benefactor can end the campaign");
        require(block.timestamp > campaign.timeline || campaign.amountRaised >= campaign.goal, "Campaign is still active");
        require(!campaign.isCompleted, "Campaign already completed");

        // Transfer the funds to the benefactor
        campaign.benefactor.transfer(campaign.amountRaised);
        campaign.isCompleted = true;

        emit CampaignCompleted(campaignId, campaign.amountRaised);
    }

    // Function to get details of a specific campaign
    function getCampaign(uint campaignId)
        public
        view
        returns (
            string memory title,
            string memory description,
            address benefactor,
            uint goal,
            uint amountRaised,
            uint256 timeline,
            bool isCompleted
        )
    {
        Campaign storage campaign = campaigns[campaignId];
        return (
            campaign.title,
            campaign.description,
            campaign.benefactor,
            campaign.goal,
            campaign.amountRaised,
            campaign.timeline,
            campaign.isCompleted
        );
    }
}
