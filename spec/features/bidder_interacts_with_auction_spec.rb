require 'rails_helper'

RSpec.feature "bidder interacts with auction", type: :feature do
  scenario "Viewing auction list and detail view as a logged out user" do
    create_current_auction

    # seeing auction list
    visit "/"
    expect(page).to have_content(@auction.title)
    expect(page).to have_content("Current Bid:")

    # going to the auction detail page
    click_on(@auction.title)
    page.find("a[href='#{@auction.issue_url}']")

    # going via another link
    visit "/"
    click_on("Details »")
    page.find("a[href='#{@auction.issue_url}']")

    # logging in via bid click
    click_on("Bid »")
    expect(page).to have_content("Authorize with GitHub")
    click_on("Authorize with GitHub")
    # completing user profile
    fill_in("user_duns_number", with: "123-duns")
    click_on('Submit')

    # bad ui brings us back to the home page :(
    click_on("Bid »")
    expect(page).to have_content("Current bid:")

    # fill in the form
    fill_in("bid_amount", with: '800')
    click_on("Submit")

    # returns us back to the bid page
    expect(page).to have_content("Current bid:")
    expect(page).to have_content("$800.00")
  end

  scenario "Bidding on an auction when logged in" do
    create_current_auction

    visit "/"
    sign_in_bidder

    click_on("Bid »")
    expect(page).not_to have_content("Authorize with GitHub")
    expect(page).to have_content("Current bid:")

    fill_in("bid_amount", with: '999')
    click_on("Submit")

    # returns us back to the bid page
    expect(page).to have_content("Current bid:")
    expect(page).to have_content("$999.00")
    expect(page).to have_content("You are currently the winning bidder.")
  end



  scenario "Is not the current winning bidder" do
    create_bidless_auction

    visit "/"
    sign_in_bidder

    click_on("Bid »")
    expect(page).not_to have_content("Authorize with GitHub")
    expect(page).to have_content("Current bid:")
    expect(page).to have_content("No bids yet.")
    expect(page).not_to have_content("You are currently the winning bidder.")
  end

  scenario "Bidding on a bid-less auction while logged in" do
    create_bidless_auction

    visit "/"
    sign_in_bidder

    click_on("Bid »")
    expect(page).not_to have_content("Authorize with GitHub")
    expect(page).to have_content("Current bid:")
    expect(page).to have_content("No bids yet.")
  end

  scenario "Viewing bid history for running auction" do
    create_running_auction
    path = "/auctions/#{@auction.id}/bids"
    visit path
    expect(page).to have_content("[Name witheld until the auction ends]")
    bids = @auction.bids
    bids.each do |bid|
      unredacted_bidder_name = bid.bidder.name
      bid = Presenter::Bid.new(bid)

      expect(page).not_to have_content(unredacted_bidder_name)
      expect(page).to(
        have_content(
          ApplicationController.helpers.number_to_currency(bid.amount)
        )
      )
    end
  end

  scenario "Viewing bid history for a closed auction" do
    create_closed_auction
    path = "/auctions/#{@auction.id}/bids"
    visit path
    bids = @auction.bids
    bids.each do |bid|
      unredacted_bidder_name = bid.bidder.name
      bid = Presenter::Bid.new(bid)

      expect(page).to have_content(unredacted_bidder_name)
      expect(page).to(
        have_content(
          ApplicationController.helpers.number_to_currency(bid.amount)
        )
      )
    end
  end
end
