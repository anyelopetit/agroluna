KepplerCattle::Engine.routes.draw do
  namespace :admin do
    scope :cattle, as: :cattle do
    end
  end
end
