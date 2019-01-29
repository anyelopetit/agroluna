# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # TransferencesController
    class TransferencesController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_transference, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@transferences)
        redirect_to_index(@objects)
      end

      # GET /cattles/1
      def show; end

      # GET /cattles/new
      def new
        @transference = Transference.new
      end

      # GET /cattles/1/edit
      def edit; end

      # POST /cattles
      def create
        @transference = Transference.new(transference_params)

        if @transference.save
          redirect(@transference, params)
        else
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @transference.update(transference_params)
          redirect(@transference, params)
        else
          render :edit
        end
      end

      def clone
        @transference = Transference.clone_record params[:transference_id]
        @transference.save
        redirect_to_index(@objects)
      end

      # DELETE /cattles/1
      def destroy
        @transference.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Transference.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Transference.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Transference.sorter(params[:row])
      end

      private

      def index_variables
        @q = Transference.ransack(params[:q])
        @transferences = @q.result(distinct: true)
        @objects = @transferences.page(@current_page).order(position: :desc)
        @total = @transferences.size
        @attributes = Transference.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_transference
        @transference = Transference.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def transference_params
        params.require(:transference).permit(
          :from_farm_id, :to_farm_id
        )
      end
    end
  end
end