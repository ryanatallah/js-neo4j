Q = require 'q'
chai = require 'chai'
chai.should()

{Neo4js} = require '../src/main'

describe 'Cypher', ->
    neo = new Neo4js()

    testNode = null

    before (done) ->
        Q.all([
            neo.createNode({ name: 'Test relationship 1' })
            neo.createNode({ name: 'Test relationship 2' })
        ])
        .then (result) ->
            testNode = result
            done()

    # Unable to run in after(), as it run before everything finish
    cleanup = ->
        Q.all([
            neo.deleteNode(testNode[0]._id)
            neo.deleteNode(testNode[1]._id)
        ])

    deleteRelationship = (relationship) ->
        describe 'deleteRelationship', ->
            it 'should pass', (done) ->
                neo.deleteRelationship(relationship._id).then((result) ->
                    result.should.be.true

                    cleanup()

                    done()
                )

    deleteRelationshipProperty = (relationship) ->
        describe 'deleteRelationshipProperty', ->
            it 'should pass', (done) ->
                Q.all([
                    neo.deleteRelationshipProperty(relationship._id, 'since')
                    neo.deleteRelationshipProperty(relationship._id)
                ])
                .then (result) ->
                    result[0].should.be.true
                    result[1].should.be.true

                    deleteRelationship(relationship)
                    done()

    readRelationshipProperty = (relationship) ->
        describe 'readRelationshipProperty', ->
            it 'should pass', (done) ->
                Q.all([
                    neo.readRelationshipProperty(relationship._id)
                    neo.readRelationshipProperty(relationship._id, 'since')
                ])
                .then (result) ->
                    result[0].since.should.equal '12 years ago'
                    result[0].sinceAge.should.equal 17

                    result[1].should.equal '12 years ago'

                    deleteRelationshipProperty(relationship)
                    done()

    updateRelationshipProperty = (relationship) ->
        describe 'updateRelationshipProperty', ->
            it 'should pass', (done) ->
                Q.all([
                    neo.updateRelationshipProperty(relationship._id, 'since', '11 years ago')
                    neo.updateRelationshipProperty(relationship._id, { 'since': '12 years ago', 'sinceAge': 17 })
                ])
                .then((result) ->
                    result[0].should.be.true
                    result[1].should.be.true

                    readRelationshipProperty(relationship)
                    done()
                )
                .fail ->
                    console.log arguments

    readRelationship = (relationship) ->
        describe 'readRelationship', ->
            it 'should pass', (done) ->
                neo.readRelationship(relationship._id)
                .then((result) ->
                    result.since.should.equal '10 years ago'

                    updateRelationshipProperty(relationship)
                    done()
                )

    createRelationship = ->
        describe 'createRelationship', ->
            it 'should pass', (done) ->
                neo.createRelationship(testNode[0]._id, testNode[1]._id, 'friend', { since: '10 years ago' }).then((relationship) ->
                    relationship.since.should.equal '10 years ago'

                    readRelationship(relationship)
                    done()
                )

    createRelationship()
