module FileTranslit
	def filename
		Translit.convert(@filename, :english) if @filename
	end
end
