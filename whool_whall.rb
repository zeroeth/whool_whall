class WhoolWhallPlugin
  include Purugin::Plugin
  description 'Whool Whall Generator', 0.1

  # TODO
  # random coridoor types, fancy 4-way intersections..
  # glass if tunnel comes in contact with air.. or water/lava

  # "2d" woven maze
  # "3d" stacked maze (pick random point as end point to next level
  # "3d" true 3d maze?
  # "plinko" 2d maze turned sideways
  
  def on_enable
    public_command('whall', 'create a kool whall whool', '/whall {length}') do |me, *args|
      length = error? args[0].to_i, "length must be an integer"
      error? length > 0, "length must be nonzero"      
      block = error? me.target_block, "No target block selected"
      type = args[1] ? args[1].to_sym : :wool

      row_block = block.block_at(:up)

      colors = org.bukkit.DyeColor.values

      length.times do |n|
	col_block = row_block

	length.times do |nn|
	  col_block.change_type type

	  state = col_block.state
	  state.data.set_color colors[rand(colors.size)] 
	  state.update

	  col_block = col_block.block_at(:west)
	end

	row_block = row_block.block_at(:up)
      end

    end
  end
end
