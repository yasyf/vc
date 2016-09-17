# VoteCollector & DRFBot

The new voting site is comprised of a website, and two Slack bots: @votebot and @drfbot. @drfbot is fully interactive, whereas @votebot only sends out notifications and will never respond to messages from a user.

Throughout this guide we refer to Trello column names from the Boston board. If these columns didn't exist for your city, they have been created, although the names might be slightly different.

## Sign Up Flow

To register for the site, simply visit http://vote.drf.vc. You will be prompted to log in with your DRF Google account. The first time you log in, you will be asked which city you're a partner in.

![City Selector](https://www.dropbox.com/s/lg8es9hvics5dbh/Screenshot%202016-09-10%2003.46.26.png?dl=1)

Once logged in, you will see one of two screens. If there are pitches to be voted on in your city, you will see a list of those companies. If not, you will see a list of recent companies that have been in your pipeline. In the former case, clicking on the company will take you to the voting form, which is described below. In the latter case, clicking on the company will take you to a summary, including voting outcome if that company pitched at some point in the past. All of this data is synced from your city's Trello board.

![Upcoming Pitches](https://www.dropbox.com/s/uux1un1wojp6bfo/Screenshot%202016-09-10%2003.46.57.png?dl=1)

Every user on the site can be in one of two states, active or inactive. This is so we know who to count for quorum purposes. If you are a current partner or will be voting on pitches, please set yourself to active from the dropdown triggered by clicking on your name in the top right corner of the site.

![Dropdown](https://www.dropbox.com/s/fv3gwmqyh8va1fs/Screenshot%202016-09-10%2003.47.20.png?dl=1)

## Managing the Pipeline

Whenever a company applies, it will instantly show up on the voting site. Once a day, @votebot will check for companies in the "Applied on Website" column, and send a reminder to your team that these companies have not been allocated point partners.

![Applied Reminder](https://www.dropbox.com/s/l6cxreai17xn6bv/Screenshot%202016-09-10%2003.52.21.png?dl=1)

To indicate that a point partners has been allocated, one should add themselves to the Trello card, and move the card into the "Allocated Point Partner" column. To make this process easier, you can also make yourself the point partner of a new company by saying "@drfbot claim COMPANY_NAME" on Slack.

![Claiming](https://www.dropbox.com/s/bh8fsl12s4b5jrf/Screenshot%202016-09-10%2003.49.15.png?dl=1)

## Voting Process

To tell the site that a company is scheduled to come and pitch, you must put the card in the "Scheduled to Pitch" column. You must also set a due date on the card, reflecting the day the company is pitching.

Once a company has been scheduled, it will show up on the home screen of the voting site. Once the pitch date has arrived, voting will be activated, and the team will have at most 2 days to summit enough votes to meet quorum. If your team does voting on the same night, then you can simply submit the votes right away, instead of waiting.

Voting occurs twice, once for a pre-vote, and once for a final vote. Thus each user can submit two votes. After your first vote (the pre-vote), the form will be populated with your initial response, but will require two extra fields: your overall vote, and your reason. All numeric fields rake values between 1 and 5 inclusive, except your overall vote, which cannot be a 3.

![Pre-Vote](https://www.dropbox.com/s/tq8b80830j28wbm/Screenshot%202016-09-10%2003.53.17.png?dl=1)

The site assumes final voting is concluded when everyone who submitted a pre-vote has also submitted a final vote. Leading up to the vote deadline, @votebot will remind people who need to submit their final vote. Once all final votes are in, @votebot will determine the funding outcome, and notify everyone by email and Slack.

![Funding Outcome](https://www.dropbox.com/s/q18rsmr6xzw1nrp/Screenshot%202016-09-10%2003.55.20.png?dl=1)

## Extras

You can stop reading now, if you'd like.

### Evergreen Knowledge

On every team, there will be pieces of information which are good to keep as a reference for future new partners. These often come up on Slack. You can now indicate these bits of information by adding an evergreen tree reaction to the message on Slack. Once a day, @votebot will collect these and add them to the collection for your city on the voting site. To view this collection, simply visit the site and click on the "Knowledge" tab.

![Evergreen](https://www.dropbox.com/s/l2bkkvrfdixyr71/Screenshot%202016-09-10%2003.59.06.png?dl=1)

### Funding Updates

@votebot will track the progress of both companies in the portfolio, as well as those we've passed on. Any time a major funding event occurs, it will post an update on Slack, and add a comment to the Trello card for that company.

![Funding Update](https://www.dropbox.com/s/ayijacj3uu7qcgw/Screenshot%202016-09-10%2004.00.16.png?dl=1)

### Company Mentions

Whenever @drfbot detects that someone is looking for more context on a portfolio company, it will show a helpful card in Slack.

![Company Mention](https://www.dropbox.com/s/y6ddemkigg7k3zz/Screenshot%202016-09-10%2004.01.37.png?dl=1)
