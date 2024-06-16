import React ,{useState} from 'react';
import Styles from './removeFacction.module.css';

const RemoveNation = () => {
    
    const Nations =['Nação 1', 'Nação 2', 'Nação 3', 'Nação 4', 'Nação 5', 'Nação 6', 'Nação 7']

    const removeFacction = (nation)=>{
        window.confirm(`deseja remover a facção de ${nation}?`)
    }
    
    return (
        <>
            
            <h3>Remover facção da nação</h3>
            <div className={Styles.container}>
                {Nations.map((nation)=>(
                    <div className={Styles.item} onClick={()=>{removeFacction(nation)}}>{nation}</div>
                ))}
            </div>
        </>
    );
};

export default RemoveNation;
