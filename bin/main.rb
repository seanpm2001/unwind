module Unwind
  def self.main(config_path)
     $logfile = File.open( "merge.log", 'w' )
    config_script = File.read( config_path )
    config = eval config_script

    repos = config.repo_configs.collect{|c|c.repo}

    loader = Unwind::DumpLoader.new(repos)
    loader.load

    source = DbRevisionSource.new( loader.db, loader.repositories )
    source = DumpFilter.new( source )

    source = PathRewritingFilter.new( source )
    source.rewrite( 'trunk/:module', ':module/trunk' )
    source.rewrite( 'trunk', 'mobicents/trunk', true )
    source.rewrite( 'tags/:tag/mobicents', 'mobicents/tags/:tag' )
    source.rewrite( 'tags/:tag', 'mobicents/tags/:tag' )
    source.rewrite( 'branches/:user/:module', ':module/branches/:user' )
    source.rewrite( 'branches/:user', 'mobicents/branches/:user' )

    source = ParentNodeCreator.new( loader.db, source )

    source = DumpFilter.new( source )
    source.exclude( /^trunk/ )
    source.exclude( /^branches/ )
    source.exclude( /^tags/ )
    source.include( /.*/ )


    #source.each do |s|
      #
    #end
    writer = Unwind::DumpWriter.new( source )
    writer.write
  end
end

$logfile = nil