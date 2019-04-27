# frozen_string_literal: true

require_dependency "keppler_reproduction/application_controller"
module KepplerReproduction
  module Admin
    # InefectivitiesController
    class InefectivitiesController < ::Admin::AdminController
      layout 'keppler_reproduction/admin/layouts/application'
      before_action :set_inefectivity, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /reproductions
      def index
        respond_to_formats(@inefectivities)
        redirect_to_index(@objects)
      end

      # GET /reproductions/1
      def show; end

      # GET /reproductions/new
      def new
        @inefectivity = Inefectivity.new
      end

      # GET /reproductions/1/edit
      def edit; end

      # POST /reproductions
      def create
        @inefectivity = Inefectivity.new(inefectivity_params)

        if @inefectivity.save
          redirect(@inefectivity, params)
        else
          render :new
        end
      end

      # PATCH/PUT /reproductions/1
      def update
        if @inefectivity.update(inefectivity_params)
          redirect(@inefectivity, params)
        else
          render :edit
        end
      end

      def clone
        @inefectivity = Inefectivity.clone_record params[:inefectivity_id]
        @inefectivity.save
        redirect_to_index(@objects)
      end

      # DELETE /reproductions/1
      def destroy
        @inefectivity.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Inefectivity.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Inefectivity.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Inefectivity.sorter(params[:row])
      end

      private

      def index_variables
        @q = Inefectivity.ransack(params[:q])
        @inefectivities = @q.result(distinct: true)
        @objects = @inefectivities.page(@current_page).order(position: :desc)
        @total = @inefectivities.size
        @attributes = Inefectivity.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_inefectivity
        @inefectivity = Inefectivity.find_by(id: params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def inefectivity_params
        params.require(:inefectivity).permit(
          :season_id, :responsable_id, :cow_id
        )
      end
    end
  end
end