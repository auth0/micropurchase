def create_bidless_auction(end_datetime: Time.now + 3.days)
  @auction = Auction.create({
    start_datetime: Time.now - 3.days,
    end_datetime: end_datetime,
    title: 'Oh no, fix the world',
    description: 'it is broken!',
    issue_url: 'https://github.com/18F/calc/issues/255',
    github_repo: 'https://github.com/18F/calc'
  })
  @bidder = User.create(
    github_id: 'uid',
    duns_number: 'duns',
    name: 'Bob the Bidder'
  )

  return @auction, @bidder
end

def create_current_auction
  @auction, @bidder = create_bidless_auction
  @auction.bids.create(bidder: @bidder, amount: 1000)
end

def create_closed_auction
  @auction, @bidder = create_bidless_auction(end_datetime: Time.now - 1.days)
  @auction.bids.create(bidder: @bidder, amount: 1000)
end

def create_running_auction
  @auction, @bidder = create_bidless_auction(end_datetime: Time.now + 1.days)
  @auction.bids.create(bidder: @bidder, amount: 1000)
end

def sign_in_admin
  mock_github(uid: Admins.github_ids.first)
  visit "/auth/github"
  @admin = User.first
end

def sign_in_bidder
  click_on "Login"
  click_on("Authorize with GitHub")
  fill_in("user_duns_number", with: "123-duns")
  click_on('Submit')
end

def create_authed_bidder
  @bidder = User.create(github_id: current_user_uid, duns_number: 'DUNS-123')
end

def show_page
  # quickly view the page visited by Capybara
  # requires the local server to be running
  # for more info: https://coderwall.com/p/jsutlq/capybara-s-save_and_open_page-with-css-and-js
  save_page Rails.root.join('public', 'capybara.html')
  %x(launchy http://localhost:3000/capybara.html)
end
