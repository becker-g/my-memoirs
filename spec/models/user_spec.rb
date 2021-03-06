require 'spec_helper'

# UnitTests for User Model
describe User do

	before do
  		@user = User.new(
  				name: "Boby Lapointe", 
  				email: "boby.lapointe@yopmail.com",
  				password: "mot2pass",
  				password_confirmation: "mot2pass")
	end

	subject { @user }

	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) }
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
	it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:memoirs) }

	it { should be_valid }
  it { should_not be_admin }


	# Name checks
	describe "when name is not present" do
  	before { @user.name = " " }
  	it { should_not be_valid }
	end

	describe "when name is too long" do
  	before { @user.name = "a" * 51 }
  	it { should_not be_valid }
	end


	# Email checks
	describe "when name is not present" do
  	before { @user.email = " " }
  	it { should_not be_valid }
	end

	describe "when email format is invalid" do
  	it "should be invalid" do
    		addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                   foo@bar_baz.com foo@bar+baz.com]
    		
    		addresses.each do |invalid_address|
      		@user.email = invalid_address
      		expect(@user).not_to be_valid
    		end
  	end
	end

	describe "when email format is valid" do
  	it "should be valid" do
    		addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
    		
    		addresses.each do |valid_address|
      		@user.email = valid_address
      		expect(@user).to be_valid
    		end
  	end
	end

	describe "when email address already exists" do
  	before do
    		user_with_same_email = @user.dup
    		user_with_same_email.email = @user.email.upcase
    		user_with_same_email.save
  	end
  	it { should_not be_valid }
	end


  # Password checks
	describe "when password is not present" do
	  	before do
	    	@user = User.new(
	    		name: "Example User", 
	    		email: "user@example.com",
             	password: " ", 
             	password_confirmation: " ")
	  	end
	  	it { should_not be_valid }
	end

	describe "when password doesn't match confirmation" do
  		before { @user.password_confirmation = "mismatch" }
  		it { should_not be_valid }
	end

	describe "with a password that's too short" do
    	before { @user.password = @user.password_confirmation = "a" * 5 }
    	it { should be_invalid }
	end

	describe "return value of authenticate method" do
  	before { @user.save }
  	let(:found_user) { User.find_by(email: @user.email) }

  	describe "with valid password" do
    		it { should eq found_user.authenticate(@user.password) }
  	end

  	describe "with invalid password" do
    		let(:user_for_invalid_password) { found_user.authenticate("invalid") }

    		it { should_not eq user_for_invalid_password }
    		specify { expect(user_for_invalid_password).to be_false }
  	end
	end

  describe "rememer tocken" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  # Admin check
  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "memoir associations" do

    before { @user.save }
    let!(:older_memoir) do
      FactoryGirl.create(:memoir, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_memoir) do
      FactoryGirl.create(:memoir, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right memoirs in the right order" do
      expect(@user.memoirs.to_a).to eq [newer_memoir, older_memoir]
    end

    it "should destroy associated memoirs" do
      memoirs = @user.memoirs.to_a
      @user.destroy
      expect(memoirs).not_to be_empty
      memoirs.each do |memoir|
        expect(Memoir.where(id: memoir.id)).to be_empty
      end
    end
  end
end
