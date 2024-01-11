class AddCommentsAndPostsReferencesToUsers < ActiveRecord::Migration[6.1]
  def change
    # Add a reference to the users table in the comments table
    add_reference :comments, :user, foreign_key: true

    # Add a reference to the users table in the posts table
    add_reference :posts, :user, foreign_key: true
  end
end
