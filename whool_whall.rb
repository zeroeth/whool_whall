class WhoolWhallPlugin
  include Purugin::Plugin
  description 'Whool Whall Generator', 0.1

  import java.awt.image.BufferedImage;
  import java.awt.image.IndexColorModel;
  import java.awt.Color
  import java.io.File;
  import javax.imageio.ImageIO;

  # TODO
  # * add url handling
  # * add scaling
  # * refactor

  def on_enable
    # TODO add hash like options.. dither:true etc..
    public_command('whall', 'create a kool whall whool', '/whall {file}') do |me, *args|

      file_name = error? args[0], "Specify a file or url"
      resize_operation = args[1] || '100%'
      error? resize_operation.match(/^\d+%$/) || resize_operation.match(/^\d+x\d+$/), "size should be blank, percent ie. 50%, or a specific resolution ie. 128x128"
      block = error? me.target_block, "No target block selected"
      # FIXME move out of enable
      colors = org.bukkit.DyeColor.values


      ### LOAD / RESAMPLE IMAGE ###

      # TODO check file error or url load error
      src_image = ImageIO.read(File.new(file_name))
      height = src_image.getHeight
      width = src_image.getWidth

      # FIXME use single array method
      color_model = IndexColorModel.new(4, 16, r_bytes, g_bytes, b_bytes)
      dest_image = BufferedImage.new width, height, BufferedImage::TYPE_BYTE_INDEXED, color_model

      # FIXME use the single array method
      width.times do |x|
	height.times do |y|
	  dest_image.setRGB(x,y, src_image.getRGB(x,y))
	end
      end


      ### LOAD PIXELS INTO ARRAY ###

      pixels = []
      height.times do |h|
        row = []
        pixels.push row
	width.times do |w|
	  color = Color.new dest_image.getRGB(w,h)
	  row.push [color.getRed, color.getGreen, color.getBlue]
	end
      end

  
      ### DRAW INTO WORLD ###

      row_block = block.block_at(:up)

      pixels.size.times do |row|
	col_block = row_block
	pixels[pixels.size-1-row].each do |col|

	  # TODO move all this into mapping
	  # so can use other things besides wool
	  col_block.change_type :wool

	  state = col_block.state
	  state.data.set_color wool_color_map[col] || colors.first
	  state.update

	  col_block = col_block.block_at(:west)
	end

	row_block = row_block.block_at(:up)
      end

    end
  end


  ### Convert to signed bytes for java

  def to_signed(num)
    if num > 127
      num - 256
    else
      num
    end
  end

  def r_bytes
    wool_color_map.keys.map{|c| to_signed(c[0])}.to_java :byte
  end
  def g_bytes
    wool_color_map.keys.map{|c| to_signed(c[1])}.to_java :byte
  end
  def b_bytes
    wool_color_map.keys.map{|c| to_signed(c[2])}.to_java :byte
  end


  ### wool color mapping
  # Order is same as bukkit enumeration
  # Colors are arbitrary from randomly sampling images of wool
  # FIXME use better color values for mapping? possibly the websafe equivalent rgb values 
  def wool_color_map
    { # R   G   B
      [240,240,240] => org.bukkit.DyeColor::WHITE,
      [235,132, 62] => org.bukkit.DyeColor::ORANGE, 
      [188, 62,199] => org.bukkit.DyeColor::MAGENTA,
      [114,147,215] => org.bukkit.DyeColor::LIGHT_BLUE, 
      [219,205, 35] => org.bukkit.DyeColor::YELLOW, 
      [ 66,205, 54] => org.bukkit.DyeColor::LIME, 
      [221,142,164] => org.bukkit.DyeColor::PINK,
      [ 72, 72, 72] => org.bukkit.DyeColor::GRAY, 
      [176,183,183] => org.bukkit.DyeColor::SILVER,  
      [ 43,129,166] => org.bukkit.DyeColor::CYAN,
      [ 45, 59,178] => org.bukkit.DyeColor::BLUE,
      [148, 77,210] => org.bukkit.DyeColor::PURPLE,
      [ 99, 59, 32] => org.bukkit.DyeColor::BROWN,
      [ 61, 85, 26] => org.bukkit.DyeColor::GREEN, 
      [177, 48, 44] => org.bukkit.DyeColor::RED, 
      [ 22, 18, 18] => org.bukkit.DyeColor::BLACK
    }
  end
end
