# frozen_string_literal: true

require_dependency "keppler_farm/application_controller"
module KepplerFarm
  module Admin
    # PhotosController
    class PhotosController < ::Admin::AdminController
      layout 'keppler_farm/admin/layouts/application'
      before_action :set_photo, only: %i[show edit update destroy]
      before_action :index_variables
      before_action :set_farm
      include ObjectQuery

      # GET /farms
      def index
        respond_to_formats(@photos)
        # redirect_to controller: :farms, action: :show, id: @farm.id
      end

      # GET /farms/1
      def show; end

      # GET /farms/new
      def new
        @photo = Photo.new
      end

      # GET /farms/1/edit
      def edit; end

      # POST /farms
      def create
        params[:photo][:photo].each do |photo|
          @photo = Photo.new(
            photo: photo,
            farm_id: @farm.id
          )
          @photo.update(cover: true) if @farm.none_cover?
          @photo.save!
        end
        redirect_to controller: :farms, action: :show, id: @farm.id
      end

      # PATCH/PUT /farms/1
      def update
        if @photo.update!(photo_params)
          redirect_to controller: :farms, action: :show, id: @farm.id
        else
          redirect_to controller: :farms, action: :show, id: @farm.id
        end
      end

      def clone
        @photo = Photo.clone_record params[:photo_id]
        @photo.save
        redirect_to controller: :farms, action: :show, id: @farm.id
      end

      # DELETE /farms/1
      def destroy
        @photo.destroy
        redirect_to controller: :farms, action: :show, id: @farm.id
      end

      def destroy_multiple
        Photo.destroy redefine_ids(params[:multiple_ids])
        redirect_to controller: :farms, action: :show, id: @farm.id
      end

      def upload
        Photo.upload(params[:file])
        redirect_to controller: :farms, action: :show, id: @farm.id
      end

      def reload; end

      def sort
        Photo.sorter(params[:row])
      end

      def toggle
        Photo.all.each { |x| x.update(cover: nil) }
        @photo = Photo.find_by(id: params[:photo_id])
        @photo.update(cover: true)
        redirect_to controller: :farms, action: :show, id: @farm.id
      end

      private

      def set_farm
        @farm = KepplerFarm::Farm.find_by(id: params[:farm_id])
      end

      def index_variables
        @q = Photo.ransack(params[:q])
        @photos = @q.result(distinct: true)
        @objects = @photos.page(@current_page).order(position: :desc)
        @total = @photos.size
        @attributes = Photo.index_attributes
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_photo
        @photo = Photo.find_by(id: params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def photo_params
        params.require(:photo).permit(
          :photo, :cover, :farm_id
        )
      end
    end
  end
end