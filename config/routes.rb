
  root 'pages#index'
  
  get 'index', to: 'pages#index'
  get 'about', to: 'pages#about'

  # The 'resources :posts' line already defines a route for 'posts#index',
  # which satisfies the requirement to retrieve all posts.
  # Therefore, the 'get 'posts', to: 'posts#index'' line is redundant and can be removed.
  # Additionally, the custom routes for show, new, create, edit, update, and delete
  # are also redundant because they are already defined by 'resources :posts'.
  # The 'all_posts' route is not needed as per the requirement.
  resources :posts

  # The following custom routes are removed as they are now handled by 'resources :posts':
  # get 'show_post/:id', to: 'posts#show', as: 'show_post'
  # get 'new_post' => 'posts#new'
  # post 'create_post' => 'posts#create'
  # get 'edit_post/:id', to: 'posts#edit', as: 'edit_post'
  # patch 'update_post/:id', to: 'posts#update', as: 'update_post'
  # delete 'delete_post/:id', to: 'posts#delete', as: 'delete_post'

end
