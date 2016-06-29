require 'grape'
require 'grape-entity'

module Srch
  class Typeahead < Grape::API

    resource :typeahead do

      # Request URL should be /api/typeahead/all/:id
      # Basic implementation from classic plots2 SearchController
      desc 'Perform a search of all available resources', {
        hidden: false,
        is_array: false,
        nickname: 'typeaheadGetAll'
      }
      params do
        requires :srchString, type: String, documentation: { example: 'Spec' }
        optional :seq, type: Integer, documentation: { example: 995 }
      end
      get :all do
        srchReq = ::Srch::Entities::SearchRequest.new
        srchReq.srchString = params[:srchString]
        srchReq.seq = params[:seq]
        sresult = ::Srch::Entities::DocList.new
        sresult.srchParams = srchReq
        unless srchReq.srchString.nil? || srchReq.srchString == 0
          sservice = SearchService.new
          # notes
          sservice.notes(id).select("title,type,nid,path").each do |match|
            doc = ::Srch::Entities::DocResult.new
            doc.docId = match.nid
            doc.docType = 'file'
            doc.docUrl = match.path
            doc.doctitle = match.title
            sresult.docs << doc
          end
          # DrupalNode search
          DrupalNode.limit(5)
          .order("nid DESC")
          .where('(type = "page" OR type = "place" OR type = "tool") AND node.status = 1 AND title LIKE ?', "%" + id + "%")
          .select("title,type,nid,path").each do |match|
            doc = ::Srch::Entities::DocResult.new
            doc.docId = match.nid
            doc.docType = match.icon
            doc.docUrl = match.path
            doc.doctitle = match.title
            sresult.docs << doc
          end
          # User profiles
          users(id).each do |match|
            doc = ::Srch::Entities::DocResult.new
            doc.docType = "user"
            doc.docUrl = "/profile/"+match.name
            doc.doctitle = match.name
            sresult.docs << doc
            matches << "<i data-url='/profile/"+match.name+"' class='fa fa-user'></i> "+match.name
          end
          # Tags
          tags(id).each do |match|
            doc = ::Srch::Entities::DocResult.new
            doc.docType = "tag"
            doc.docUrl = "/tag/"+match.name
            doc.doctitle = match.name
            sresult.docs << doc
          end
          # maps
          maps(id).select("title,type,nid,path").each do |match|
            doc = ::Srch::Entities::DocResult.new
            doc.docId = match.nid
            doc.docType = match.icon
            doc.docUrl = match.path
            doc.doctitle = match.title
            sresult.docs << doc
          end
        end
	return sresult
      end

      get :test do
        { sresult: 'success!' }
      end
    end

  end
end
