# VoteCollector & DRFBot

If you're a DRF partner and are looking for the walkthrough, [go here](WALKTHROUGH.md).

VoteCollector is the new pipeline management and vote collection web app that's currently being used by the Boston DRF team. The hope is to expand it very quickly to the other cities. Its accompanied by two Slack bots: VoteBot and DRFBot.

VoteBot is a notifications-only bot that communicates with the team about new applications, upcoming pitches, funding decisions, and funding updates for any company either in the portfolio or in our pipeline (including companies we've passed on).

![Funding Update](https://www.dropbox.com/s/ayijacj3uu7qcgw/Screenshot%202016-09-10%2004.00.16.png?dl=1)

DRFBot is an interactive bot which can respond to queries about companies in the pipeline, portfolio, and more.

![DRDBot Queries](https://www.dropbox.com/s/kifco4rmopma45c/Screenshot%202016-09-15%2003.36.10.png?dl=1)

## Motivation

Historically, all of the cities had independent voting processes that were ad-hoc and often cobbled together with age-old Google forms. Data was hard to sift through, voting outcomes were all handled manually, and the nothing about the flow was enjoyable for anyone. VC looks to solve those issues by offering a centralized location for vote data input and management, as well as an easy way to view and analyze historical data, complete with a full (authenticated) API.

The primary source of truth for the pipeline is still Trello. VC simply tracks and augments the data in the Trello boards used by each city.

In addition to being a centralized voting platform, using Slack bots allows us to get realtime information sharing between cities, and near-instant updates on funding news that would otherwise take a long time to spread throughout the network.

# Voting

All voting is done through the platform. A partner simply has to move a Trello card into the "Scheduled to Pitch" column for their city in order to let the system know to prepare. Adding a due date to this card sets off a series of events, including notifications to the entire DRF community.

![Upcoming Pitch](https://www.dropbox.com/s/b1cc80v53ococgh/Screenshot%202016-09-15%2003.34.04.png?dl=1)

In addition to handling the actual voting, the platform automatically sends out funding decisions to the community.

![Funding Outcome](https://www.dropbox.com/s/q18rsmr6xzw1nrp/Screenshot%202016-09-10%2003.55.20.png?dl=1)

VC also provides a summary of votes for anyone to see in a easy-to-digest email upon a city deciding to fund a company.

![Vote Summary](https://www.dropbox.com/s/hxh23n6isghxq0g/Screenshot%202016-09-15%2003.45.55.png?dl=1)

## Managing the Pipeline

Whenever a company applies, it will instantly show up on the platform. Partners use DRFBot to allocate points, ensuring constant and clear communication with their team.

![Claiming](https://www.dropbox.com/s/bh8fsl12s4b5jrf/Screenshot%202016-09-10%2003.49.15.png?dl=1)

Having applications tracked by the system also ensures companies are never forgotten about.

![Applied Reminder](https://www.dropbox.com/s/l6cxreai17xn6bv/Screenshot%202016-09-10%2003.52.21.png?dl=1)

The system is constantly reflecting any changes to the pipeline on Trello, ensuring that everyone is always in sync.


## Extras

To assist in other day-to-day tasks of partners, the system has a suite of other features, some of which are documented below. Future planned work includes the standardization and automation of the snapshot creation and management process.

### Evergreen Knowledge

The partners of the Boston team have discovered that small tidbits of information which would be crucial to new partners are constantly being shared on Slack. VC now monitors all Slack messages, and collects any which have an evergreen tree reaction added to them, saving them for future onboarding sessions.

![Evergreen](https://www.dropbox.com/s/l2bkkvrfdixyr71/Screenshot%202016-09-10%2003.59.06.png?dl=1)

### Company Mentions

Whenever DRFBot detects that someone is looking for more context on a portfolio company, it will show a helpful card in Slack. This includes information on our voting process, how much total money the company has raised to date, and whether or not some of our competitors have funded the company.

![Company Mention](https://www.dropbox.com/s/y6ddemkigg7k3zz/Screenshot%202016-09-10%2004.01.37.png?dl=1)
