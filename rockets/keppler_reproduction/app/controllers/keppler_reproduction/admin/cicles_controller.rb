# frozen_string_literal: true

require_dependency "keppler_reproduction/application_controller"
module KepplerReproduction
  module Admin
    # CiclesController
    class CiclesController < ::Admin::AdminController
      layout 'keppler_reproduction/admin/layouts/application'
      before_action :set_cicle, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /reproductions
      def index
        respond_to_formats(@cicles)
        redirect_to_index(@objects)
      end

      # GET /reproductions/1
      def show; end

      # GET /reproductions/new
      def new
        @cicle = Cicle.new
      end

      # GET /reproductions/1/edit
      def edit; end

      # POST /reproductions
      def create
        @cicle = Cicle.new(cicle_params)

        if @cicle.save
          redirect(@cicle, params)
        else
          render :new
        end
      end

      # PATCH/PUT /reproductions/1
      def update
        if @cicle.update(cicle_params)
          redirect(@cicle, params)
        else
          render :edit
        end
      end

      def clone
        @cicle = Cicle.clone_record params[:cicle_id]
        @cicle.save
        redirect_to_index(@objects)
      end

      # DELETE /reproductions/1
      def destroy
        @cicle.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Cicle.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Cicle.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Cicle.sorter(params[:row])
      end

      private

      def index_variables
        @q = Cicle.ransack(params[:q])
        @cicles = @q.result(distinct: true)
        @objects = @cicles.page(@current_page).order(position: :desc)
        @total = @cicles.size
        @attributes = Cicle.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_cicle
        @cicle = Cicle.find_by(id: params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def cicle_params
        params.require(:cicle).permit(
          :name, :days_count, :start_date, :end_date, :season_id
        )
      end
    end
  end
end