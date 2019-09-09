# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # MedicalHistoriesController
    class MedicalHistoriesController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_medical_history, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@medical_histories)
        redirect_to_index(@objects)
      end

      # GET /cattles/1
      def show; end

      # GET /cattles/new
      def new
        @medical_history = MedicalHistory.new
      end

      # GET /cattles/1/edit
      def edit; end

      # POST /cattles
      def create
        @medical_history = MedicalHistory.new(medical_history_params)

        if @medical_history.save
          redirect(@medical_history, params)
        else
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @medical_history.update(medical_history_params)
          redirect(@medical_history, params)
        else
          render :edit
        end
      end

      def clone
        @medical_history = MedicalHistory.clone_record params[:medical_history_id]
        @medical_history.save
        redirect_to_index(@objects)
      end

      # DELETE /cattles/1
      def destroy
        @medical_history.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        MedicalHistory.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        MedicalHistory.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        MedicalHistory.sorter(params[:row])
      end

      private

      def index_variables
        @q = MedicalHistory.ransack(params[:q])
        @medical_histories = @q.result(distinct: true)
        @objects = @medical_histories.page(@current_page).order(position: :desc)
        @total = @medical_histories.size
        @attributes = MedicalHistory.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_medical_history
        @medical_history = MedicalHistory.find_by(id: params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def medical_history_params
        params.require(:medical_history).permit(
          :evaluation_date, :user_id, :evualuation, :diagnostic, :next_date
        )
      end
    end
  end
end