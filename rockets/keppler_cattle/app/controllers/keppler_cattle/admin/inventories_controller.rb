# frozen_string_literal: true

require_dependency "keppler_cattle/application_controller"
module KepplerCattle
  module Admin
    # InventoriesController
    class InventoriesController < ::Admin::AdminController
      layout 'keppler_cattle/admin/layouts/application'
      before_action :set_inventory, only: %i[show edit update destroy]
      before_action :index_variables
      include ObjectQuery

      # GET /cattles
      def index
        respond_to_formats(@inventories)
        redirect_to_index(@objects)
      end

      # GET /cattles/1
      def show; end

      # GET /cattles/new
      def new
        @inventory = Inventory.new
      end

      # GET /cattles/1/edit
      def edit; end

      # POST /cattles
      def create
        @inventory = Inventory.new(inventory_params)

        if @inventory.save
          redirect(@inventory, params)
        else
          render :new
        end
      end

      # PATCH/PUT /cattles/1
      def update
        if @inventory.update(inventory_params)
          redirect(@inventory, params)
        else
          render :edit
        end
      end

      def clone
        @inventory = Inventory.clone_record params[:inventory_id]
        @inventory.save
        redirect_to_index(@objects)
      end

      # DELETE /cattles/1
      def destroy
        @inventory.destroy
        redirect_to_index(@objects)
      end

      def destroy_multiple
        Inventory.destroy redefine_ids(params[:multiple_ids])
        redirect_to_index(@objects)
      end

      def upload
        Inventory.upload(params[:file])
        redirect_to_index(@objects)
      end

      def reload; end

      def sort
        Inventory.sorter(params[:row])
      end

      private

      def index_variables
        @q = Inventory.ransack(params[:q])
        @inventories = @q.result(distinct: true)
        @objects = @inventories.page(@current_page).order(position: :desc)
        @total = @inventories.size
        @attributes = Inventory.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_inventory
        @inventory = Inventory.find_by(id: params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def inventory_params
        params.require(:inventory).permit(
          :cow_id, :found
        )
      end
    end
  end
end