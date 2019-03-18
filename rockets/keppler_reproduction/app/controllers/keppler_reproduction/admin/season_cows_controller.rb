# frozen_string_literal: true

require_dependency "keppler_reproduction/application_controller"
module KepplerReproduction
  module Admin
    # SeasonCowsController
    class SeasonCowsController < ::Admin::AdminController
      layout 'keppler_reproduction/admin/layouts/application'
      before_action :set_season_cow, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /reproductions
      def index
        respond_to_formats(@season_cows)
        redirect_to_index(@objects)
      end

      # GET /reproductions/1
      def show; end

      # GET /reproductions/new
      def new
        @season_cow = SeasonCow.new
      end

      # GET /reproductions/1/edit
      def edit; end

      # POST /reproductions
      def create
        @season_cow = SeasonCow.new(season_cow_params)

        if @season_cow.save
          redirect(@season_cow, params)
        else
          render :new
        end
      end

      # PATCH/PUT /reproductions/1
      def update
        if @season_cow.update(season_cow_params)
          redirect(@season_cow, params)
        else
          render :edit
        end
      end

      def clone
        @season_cow = SeasonCow.clone_record params[:season_cow_id]
        @season_cow.save
        redirect_to_index(@objects)
      end

      # DELETE /reproductions/1
      def destroy
        @season_cow.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        SeasonCow.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        SeasonCow.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        SeasonCow.sorter(params[:row])
      end

      private

      def index_variables
        @q = SeasonCow.ransack(params[:q])
        @season_cows = @q.result(distinct: true)
        @objects = @season_cows.page(@current_page).order(position: :desc)
        @total = @season_cows.size
        @attributes = SeasonCow.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_season_cow
        @season_cow = SeasonCow.find_by(id: params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def season_cow_params
        params.require(:season_cow).permit(
          :season_id, :cow_id
        )
      end
    end
  end
end