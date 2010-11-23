class AccountsController < ApplicationController
  before_filter :find_account, :only => [:edit, :update, :destroy]

  # GET /accounts
  def index
    @accounts = Account.all
  end

  # GET /accounts/1
  def show
    @account = Account.find(params[:id], :include => {:category => {:activities => :activity_project}})
    @projects = @account.projects rescue []
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end

  # POST /accounts
  def create
    @account = Account.new(params[:account])

    respond_to do |format|
      if @account.save
        format.html { redirect_to(edit_account_path(@account), :notice => 'Please select the company you work for.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /accounts/1
  def update
    respond_to do |format|
      if @account.update_attributes(params[:account])
        if @account.user_id.blank?
          format.html { redirect_to(edit_account_path(@account), :notice => 'Please select your user account.') }
        else
          format.html { redirect_to(@account, :notice => 'Account was successfully updated.') }
        end
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /accounts/1
  def destroy
    @account.destroy

    respond_to do |format|
      format.html { redirect_to(accounts_url) }
    end
  end

protected
  
  def find_account
    @account = Account.find(params[:id])
  end
end
