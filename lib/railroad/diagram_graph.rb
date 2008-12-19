# RailRoad - RoR diagrams generator
# http://railroad.rubyforge.org
#
# Copyright 2007-2008 - Javier Smaldone (http://www.smaldone.com.ar)
# See COPYING for more details
#
# Dec 2008 - Roy Wright
# minor isolation from framework

# RailRoad diagram structure
class DiagramGraph
  attr_accessor :migration_version
  def initialize
    @migration_version = nil
    @diagram_type = ''
    @show_label = false
    @nodes = []
    @edges = []
  end 

  def add_node(node)
    @nodes << node
  end

  def add_edge(edge)
    @edges << edge
  end
  
  def diagram_type= (type)
    @diagram_type = type
  end

  def show_label= (value)
    @show_label = value
  end


  # Generate DOT graph
  def to_dot
    return dot_header +
           @nodes.uniq.map{|n| dot_node n[0], n[1], n[2]}.join +
           @edges.uniq.map{|e| dot_edge e[0], e[1], e[2], e[3]}.join +
           dot_footer
  end
  
  # Generate XMI diagram (not yet implemented)
  def to_xmi
     STDERR.print "Sorry. XMI output not yet implemented.\n\n"
     return ""
  end

  private

  # Build DOT diagram header
  def dot_header
    result = "digraph #{@diagram_type.downcase}_diagram {\n" +
             "\tgraph[overlap=false, splines=true]\n"
    result += dot_label if @show_label
    return result
  end

  # Build DOT diagram footer
  def dot_footer
    return "}\n"
  end
  
  # Build diagram label
  def dot_label
    buf = []
    buf << "\t_diagram_info [shape=\"plaintext\", "
    buf << "label=\"#{@diagram_type} diagram\\l"
    buf << "Date: #{Time.now.strftime "%b %d %Y - %H:%M"}\\l"
    unless @migration_version.nil?
      buf << "Migration version: #{@migration_version}\\l"
    end
    buf << "Generated by #{APP_HUMAN_NAME} #{APP_VERSION.join('.')}"
    buf << "\\l\", fontsize=14]\n"
    buf.join('')
  end

  # Build a DOT graph node
  def dot_node(type, name, attributes=nil)
    case type
      when 'model'
           options = 'shape=Mrecord, label="{' + name + '|'
           options += attributes.join('\l')
           options += '\l}"'
      when 'model-brief'
           options = ''
      when 'class'
           options = 'shape=record, label="{' + name + '|}"' 
      when 'class-brief'
           options = 'shape=box' 
      when 'controller'
           options = 'shape=Mrecord, label="{' + name + '|'
           public_methods    = attributes[:public].join('\l')
           protected_methods = attributes[:protected].join('\l')
           private_methods   = attributes[:private].join('\l')
           options += public_methods + '\l|' + protected_methods + '\l|' + 
                      private_methods + '\l'
           options += '}"'
      when 'controller-brief'
           options = '' 
      when 'module'
           options = 'shape=box, style=dotted, label="' + name + '"'
      when 'aasm'
           # Return subgraph format
           return "subgraph cluster_#{name.downcase} {\n\tlabel = #{quote(name)}\n\t#{attributes.join("\n  ")}}"
    end # case
    return "\t#{quote(name)} [#{options}]\n"
  end # dot_node

  # Build a DOT graph edge
  def dot_edge(type, from, to, name = '')
    options =  name != '' ? "label=\"#{name}\", " : ''
    case type
      when 'one-one'
           #options += 'taillabel="1"'
           options += 'arrowtail=odot, arrowhead=dot, dir=both'
      when 'one-many'
	   #options += 'taillabel="n"'
           options += 'arrowtail=crow, arrowhead=dot, dir=both'                    
      when 'many-many'
           #options += 'taillabel="n", headlabel="n", arrowtail="normal"'
           options += 'arrowtail=crow, arrowhead=crow, dir=both'
      when 'is-a'
           options += 'arrowhead="none", arrowtail="onormal"'
      when 'event'
           options += "fontsize=10"
    end
    return "\t#{quote(from)} -> #{quote(to)} [#{options}]\n"
  end # dot_edge

  # Quotes a class name
  def quote(name)
    '"' + name.to_s + '"'
  end
  
end # class DiagramGraph
