//
//  PlayPortalNoteClient.swift
//  PPSDK-Swift
//
//  Created by Lincoln Fraley on 4/15/20.
//

import Foundation

class NoteEndpoints: EndpointsBase {
  
  private static let base = NoteEndpoints.host + "/edu/v1/note"
  static let note = NoteEndpoints.base
  static let list = NoteEndpoints.note + "/list"
  static let remove = NoteEndpoints.note + "/remove"
}

//  Responsible for making requests to the note API
public final class PlayPortalNoteClient: PlayPortalHTTPClient {
  
  public static let shared = PlayPortalNoteClient()
  
  private override init() {}
  
  
  /**
   Creates a note.
   - Parameter text: Text of note.
   - Parameter lessonId: ID of lesson to which this note refers.
   - Parameter userId: ID of user profile to whom this note refers.
   - Parameter classId: ID of class to which this note refers.
   - Parameter studentId: ID of student to whom this note refers.
   - Parameter courseId: ID of course to which this note refers.
   - Parameter completion: Closure invoked when the request finishes. Called with an `Error`
      argument if the request fails; otherwise, called with the created note.
   */
  public func createNote(
    text: String,
    lessondId: String?,
    userId: String?,
    classId: String?,
    studentId: String?,
    courseId: String?,
    _ completion: @escaping (_ error: Error?, _ note: PlayPortalNote?) -> Void
  ) {
    let body: [String: Any?] = [
      "text": text,
      "lessondId": lessondId,
      "userId": userId,
      "classId": classId,
      "studentId": studentId,
      "courseId": courseId,
    ]
    
    request(
      url: NoteEndpoints.note,
      method: .put,
      body: body,
      completionWithDecodableResult: completion
    )
  }
  
  /**
   Retrieves a specific note by ID.
   - Parameter noteId: ID of the note to return.
   - Parameter completion: Closure invoked when the request finishes. Called with an `Error`
      argument if the request fails; otherwise, called with the requested note.
   */
  public func getNote(
    noteId: String,
    _ completion: @escaping (_ error: Error?, _ note: PlayPortalNote?) -> Void
  ) {
    let params: [String: Any] = [
      "noteId": noteId
    ]
    
    request(
      url: NoteEndpoints.note,
      method: .get,
      queryParameters: params,
      completionWithDecodableResult: completion
    )
  }
  
  /**
   Retrieves all notes from the specified category or categories.
   - Parameter lessonId: A lessonId to which the desired notes are related.
   - Parameter userId: A user account ID to whom the notes are related.
   - Parameter classId: A class ID to which the notes are related.
   - Parameter studentId: A student ID to whom the notes are related.
   - Parameter courseId: A course ID to which the desired notes are related.
   */
  public func getNoteList(
    lessondId: String?,
    userId: String?,
    classId: String?,
    studentId: String?,
    courseId: String?,
    _ completion: @escaping (_ error: Error?, _ notes: [PlayPortalNote]?) -> Void
  ) {
    let params: [String: Any?] = [
      "lessondId": lessondId,
      "userId": userId,
      "classId": classId,
      "studentId": studentId,
      "courseId": courseId,
    ]
    
    request(
      url: NoteEndpoints.list,
      method: .get,
      queryParameters: params,
      completionWithDecodableResult: completion
    )
  }
  
  public func deleteNote(
    noteId: String,
    _ completion: @escaping (_ error: Error?) -> Void
  ) {
    let body: [String: Any?] = [
      "noteId": noteId
    ]
    
    request(
      url: NoteEndpoints.remove,
      method: .post,
      body: body,
      completionWithNoResult: completion
    )
  }
}

