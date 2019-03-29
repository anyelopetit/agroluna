# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # StatusesController
    class StatusesController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_status, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@statuses)
        redirect_to_index(@objects)
      end

      # GET /cattles/1
      def show; end

      # GET /cattles/new
      def new
        @status = Status.new
      end

      # GET /cattles/1/edit
      def edit; end

      # POST /cattles
      def create
        @status = Status.new(status_params)

        if @status.save
          redirect(@status, params)
        else
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @status.update(status_params)
          redirect(@status, params)
        else
          render :edit
        end
      end

      def clone
        @status = Status.clone_record params[:status_id]
        @status.save
        redirect_to_index(@objects)
      end

      # DELETE /cattles/1
      def destroy
        @status.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Status.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Status.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Status.sorter(params[:row])
      end

      private

      def index_variables
        @q = Status.ransack(params[:q])
        @statuses = @q.result(distinct: true)
        @objects = @statuses.page(@current_page).order(position: :desc)
        @total = @statuses.size
        @attributes = Status.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_status
        @status = Status.find_by(id: params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def status_params
        params.require(:status).permit(
          :date, :months, :successfully, :twins, :observations, :bull_id, :user_id
        )
      end
    end
  end
end