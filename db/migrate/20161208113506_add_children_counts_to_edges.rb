class AddChildrenCountsToEdges < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'hstore'
    add_column :edges, :children_counts, :hstore, default: {}

    Edge.reset_column_information

    Edge.where(owner_type: 'Argument').find_each do |edge|
      edge.children_counts = {
        comments: edge.owner.comments_count,
        votes_pro: edge.owner.votes_pro_count,
        votes_con: edge.owner.votes_con_count
      }
      edge.save!
    end
    puts "Processed #{Edge.where(owner_type: 'Argument').count} arguments"
    Edge.where(owner_type: 'BlogPost').find_each do |edge|
      edge.children_counts = {
        comments: edge.owner.comments_count
      }
      edge.save!
    end
    puts "Processed #{Edge.where(owner_type: 'BlogPost').count} blogsposts"
    Edge.where(owner_type: 'Forum').find_each do |edge|
      edge.children_counts = {
        questions: edge.children.where(owner_type: 'Question', is_published: true, trashed_at: nil).count,
        motions: edge.children.where(owner_type: 'Motion', is_published: true, trashed_at: nil).count,
        projects: edge.owner.projects_count,
      }
      edge.save!
    end
    puts "Processed #{Edge.where(owner_type: 'Forum').count} forums"
    Edge.where(owner_type: 'Motion').find_each do |edge|
      edge.children_counts = {
        votes_pro: edge.owner.votes_pro_count,
        votes_con: edge.owner.votes_con_count,
        votes_neutral: edge.owner.votes_neutral_count,
        arguments_pro: edge.owner.argument_pro_count,
        arguments_con: edge.owner.argument_con_count,
        blog_posts: edge.owner.blog_posts.published.count,
      }
      edge.save!
    end
    puts "Processed #{Edge.where(owner_type: 'Motion').count} motions"
    Edge.where(owner_type: 'Project').find_each do |edge|
      edge.children_counts = {
        questions: edge.children.where(owner_type: 'Question', is_published: true, trashed_at: nil).count,
        motions: edge.children.where(owner_type: 'Motion', is_published: true, trashed_at: nil).count,
        phases: edge.owner.phases_count,
        blog_posts: edge.owner.blog_posts_count,
      }
      edge.save!
    end
    puts "Processed #{Edge.where(owner_type: 'Project').count} projects"
    Edge.where(owner_type: 'Question').find_each do |edge|
      edge.children_counts = {
        motions: edge.owner.motions_count,
        blog_posts: edge.owner.blog_posts.published.count,
      }
      edge.save!
    end
    puts "Processed #{Edge.where(owner_type: 'Question').count} questions"
  end
end
