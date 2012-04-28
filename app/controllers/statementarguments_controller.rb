class StatementargumentsController < ApplicationController
  # GET /statementarguments
  # GET /statementarguments.json
  def index
    @statementarguments = Statementargument.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @statementarguments }
    end
  end

  # GET /statementarguments/1
  # GET /statementarguments/1.json
  def show
    @statementargument = Statementargument.find(params[:statement_id, :argument_id, :pro])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @statementargument }
    end
  end

  # GET /statementarguments/new
  # GET /statementarguments/new.json
  def new
    @statementargument = Statementargument.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @statementargument }
    end
  end

  # GET /statementarguments/1/edit
  def edit
    @statementargument = Statementargument.find(params[:statement_id, :argument_id, :pro])
  end

  # POST /statementarguments
  # POST /statementarguments.json
  def create
    @statementargument = Statementargument.new(params[:statementargument])

    respond_to do |format|
      if @statementargument.save
        format.html { redirect_to @statementargument, notice: 'Statementargument was successfully created.' }
        format.json { render json: @statementargument, status: :created, location: @statementargument }
      else
        format.html { render action: "new" }
        format.json { render json: @statementargument.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /statementarguments/1
  # PUT /statementarguments/1.json
  def update
    @statementargument = Statementargument.find(params[:statement_id, :argument_id, :pro])

    respond_to do |format|
      if @statementargument.update_attributes(params[:statementargument])
        format.html { redirect_to @statementargument, notice: 'Statementargument was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @statementargument.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statementarguments/1
  # DELETE /statementarguments/1.json
  def destroy
    @statementargument = Statementargument.find(params[:statement_id, :argument_id, :pro])
    @statementargument.destroy

    respond_to do |format|
      format.html { redirect_to statementarguments_url }
      format.json { head :no_content }
    end
  end
end
