#! /usr/bin/env ruby

os_versions = {
	alpine: [],
	debian: [],
	ubuntu: [],
}

tdlib_versions = []

image_names = []

puts 'Alpine versions? (end with empty line)'
loop do
	line = gets
	if line.nil?
		break
	end

	version, *aliases = line.strip.split('|')
	if version.nil?
		break
	end
	if aliases.empty?
		aliases.append "alpine-#{version}"
	end
	os_versions[:alpine].append({
		version: version,
		aliases: aliases,
	})
end

puts 'Debian versions? (end with empty line)'
loop do
	line = gets
	if line.nil?
		break
	end
	version, *aliases = line.strip.split('|')
	if version.nil?
		break
	end
	if aliases.empty?
		aliases.append "debian-#{version}"
	end
	os_versions[:debian].append({
		version: version,
		aliases: aliases,
	})
end

puts 'Ubuntu versions? (end with empty line)'
loop do
	line = gets
	if line.nil?
		break
	end
	version, *aliases = line.strip.split('|')
	if version.nil?
		break
	end
	if aliases.empty?
		aliases.append "ubuntu-#{version}"
	end
	os_versions[:ubuntu].append({
		version: version,
		aliases: aliases,
	})
end

puts 'tdlib commits? (end with empty line; tag:XXX to insert tag name)'
loop do
	line = gets
	if line.nil?
		break
	end
	commit, *aliases = line.strip.split('|')
	if commit.nil?
		break
	end
	if commit.start_with? 'tag:'
		tag = commit[4..]
		commit = nil
	end
	if aliases.empty?
		if commit.nil?
			aliases.append tag
		else
			aliases.append commit
		end
	end
	tdlib_versions.append({
		tag: tag,
		commit: commit,
		aliases: aliases,
	})
end

puts 'Image names? (end with empty line)'
loop do
	line = gets
	if line.nil?
		break
	end
	image_names.append(line.strip)
end
if image_names.empty?
	image_names.append "tdlib"
end

def get_script os
	case os
	when :alpine
		'./alpine/build.sh'
	when :debian
		'./debian/build.sh'
	when :ubuntu
		'./ubuntu/build.sh'
	else
		fail "Unknown OS: #{os}"
	end
end

def get_tdlib_ver_print tdlib_ver
	if not tdlib_ver[:tag].nil?
		"tags/#{tdlib_ver[:tag]}"
	else
		tdlib_ver[:commit]
	end
end

failures = 0
os_versions.each_pair do |os, os_versions|
	script = get_script os
	os_versions.each do |os_version|
		tdlib_versions.each do |tdlib_version|
			puts "\x1b[94mNow building \x1b[92m#{os}:#{os_version[:version]}\x1b[94m, TDLIB: \x1b[92m#{get_tdlib_ver_print(tdlib_version)}\x1b[39m"
			if not tdlib_version[:tag].nil?
				success = system(
					{"IMAGE_TAG" => "tdlib:ruby_temp_img", "SO_IMAGE_TAG" => "tdlib:ruby_temp_img_so"},
					"./#{File.basename("./build.sh")}", 
					"-v", 
					os_version[:version],
					"-t",
					tdlib_version[:tag],
					chdir: File.dirname(File.realpath(script)),
					exception: true,
				)
			else
				success = system(
					{"IMAGE_TAG" => "tdlib:ruby_temp_img", "SO_IMAGE_TAG" => "tdlib:ruby_temp_img_so"},
					"./#{File.basename("./build.sh")}", 
					"-v", 
					os_version[:version],
					"-c",
					tdlib_version[:commit],
					chdir: File.dirname(File.realpath(script)),
					exception: true,
				)
			end
			if success
				puts "Image build, tagging..."
				image_names.each do |img_name|
					os_version[:aliases].each do |os_alias|
						tdlib_version[:aliases].each do |tdlib_alias|
							tag = "#{img_name}:#{tdlib_alias}-#{os_alias}"
							system(
								"docker", 
								"tag", 
								"tdlib:ruby_temp_img",
								tag
							)
							puts "\x1b[37m- \x1b[92m#{tag}\x1b[39m"
						end
					end
				end
				image_names.each do |img_name|
					os_version[:aliases].each do |os_alias|
						tdlib_version[:aliases].each do |tdlib_alias|
							tag = "#{img_name}:so-#{tdlib_alias}-#{os_alias}"
							system(
								"docker", 
								"tag", 
								"tdlib:ruby_temp_img_so",
								tag
							)
							puts "\x1b[37m- \x1b[92m#{tag}\x1b[39m"
						end
					end
				end
				system("docker", "image", "rm", "tdlib:ruby_temp_img")
				system("docker", "image", "rm", "tdlib:ruby_temp_img_so")
			else
				$stderr.puts "Failed!"
				failures += 1
			end
		end
	end
end

if failures != 0
	exit 1
end
