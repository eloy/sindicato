Sindicato::Application.routes.draw do
  post '/export' => 'site#export', as: 'export'
  root :to => 'site#index'
end
