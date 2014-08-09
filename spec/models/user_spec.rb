require 'spec_helper'

describe User do
  before do 
    @user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }


  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attributes set to true" do
    before do
      @user.save! 
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "remember_token" do
    before {@user.save}
    its(:remember_token) {should_not be_blank}
  end

  describe "email address is mixed case" do
    let(:mixed_case_email) { "Foo@ExamPle.com" }

    it "should all be saved in lowercase" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe "when name is not present" do
  	before { @user.name = " " }
  	it { should_not be_valid }
  end

  describe "when name is too long" do
  	before { @user.name = "a" * 51 }
  	it { should_not be_valid }
  end

  describe "when email is not present" do
  	before { @user.email = "" }
  	it { should_not be_valid }
  end

  describe "when email format is invalid" do
  	it "should be invalid" do
  		addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_bz.com foo@bar+barz.com foo@bar..com]
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

  describe "when email is already taken" do
  	before do 
  		user_with_same_email = @user.dup
  		user_with_same_email.email = @user.email.upcase

  		user_with_same_email.save
  	end

  	it { should_not be_valid }
  end

  describe "when a password is too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid}
  end

  describe "return value of authenticate method" do
    before(:each) { @user.save! }
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


  describe "when password is not present" do
    before do
      @user = User.new( name: "Example User", email: "user@example.com", password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password does not match confirmation" do
    before { @user.password_confirmation = "mismatch"}
    it { should_not be_valid }
  end
end
