import React ,{useState} from 'react';
import Styles from './changeLeader.module.css';

const ChangeLeaderFacction = () => {
    
    const leaders =['Lusca', 'Theo', 'Pedro', 'Gui', 'Afonso', 'Andre', 'Elaine']

    const changeLeader = (leader)=>{
        window.confirm(`deseja indicar ${leader} como novo lider?`)
    }
    
    return (
        <>
            <h3>Indicar novo Lider</h3>
            <div className={Styles.container}>
                {leaders.map((leader)=>(
                    <div className={Styles.item} onClick={()=>{changeLeader(leader)}}>{leader}</div>
                ))}
            </div>
        </>
    );
};

export default ChangeLeaderFacction;
