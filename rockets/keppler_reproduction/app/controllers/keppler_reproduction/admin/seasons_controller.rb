# frozen_string_literal: true

require_dependency "keppler_reproduction/application_controller"
module KepplerReproduction
  module Admin
    # SeasonsController
    class SeasonsController < ::Admin::AdminController
      layout 'keppler_reproduction/admin/layouts/application'
      before_action :set_season, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /reproductions
      def index
        respond_to_formats(@seasons)
        redirect_to_index(@objects)
      end

      # GET /reproductions/1
      def show; end

      # GET /reproductions/new
      def new
        @season = Season.new
      end

      # GET /reproductions/1/edit
      def edit; end

      # POST /reproductions
      def create
        @season = Season.new(season_params)

        if @season.save
          redirect(@season, params)
        else
          render :new
        end
      end

      # PATCH/PUT /reproductions/1
      def update
        if @season.update(season_params)
          redirect(@season, params)
        else
          render :edit
        end
      end

      def clone
        @season = Season.clone_record params[:season_id]
        @season.save
        redirect_to_index(@objects)
      end

      # DELETE /reproductions/1
      def destroy
        @season.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Season.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Season.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Season.sorter(params[:row])
      end

      private

      def index_variables
        @q = Season.ransack(params[:q])
        @seasons = @q.result(distinct: true)
        @objects = @seasons.page(@current_page).order(position: :desc)
        @total = @seasons.size
        @attributes = Season.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_season
        @season = Season.find_by(id: params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def season_params
        params.require(:season).permit(
          :name, :start_date, :farm_id
        )
      end
    end
  end
end